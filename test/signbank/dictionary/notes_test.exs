defmodule Signbank.Dictionary.NotesTest do
  use Signbank.DataCase, async: true

  import Phoenix.LiveViewTest, only: [rendered_to_string: 1]
  import Phoenix.Component, only: [sigil_H: 2]

  alias Signbank.Accounts.User
  alias Signbank.Dictionary
  alias Signbank.Dictionary.{Definition, Note, Sign}

  defp insert_sign!(attrs) do
    Repo.insert!(
      struct!(
        %Sign{
          type: :citation,
          id_gloss_annotation: "TEST",
          published: true,
          crude: false,
          morphology: %{},
          phonology: %{}
        },
        attrs
      )
    )
  end

  defp load(id_gloss) do
    Dictionary.get_sign_by_id_gloss(id_gloss, %{user: %User{role: :editor}})
  end

  setup do
    citation =
      insert_sign!(
        id_gloss: "test1a",
        definitions: [
          %Definition{
            text: "A question.",
            role: :question,
            pos: 0,
            language: "en",
            published: true
          }
        ],
        notes: [
          %Note{text: "Public note.", type: :note, pos: 0, published: true},
          %Note{text: "Unpublished note.", type: :note, pos: 1, published: false},
          %Note{text: "Editor only.", type: :editor_note, pos: 2, published: true}
        ]
      )

    variant = insert_sign!(id_gloss: "test1b", type: :variant, variant_of_id: citation.id)

    %{citation: citation, variant: variant}
  end

  defp render_definitions(sign, user \\ nil) do
    assigns = %{sign: sign, user: user}

    rendered_to_string(~H"""
    <SignbankWeb.SignComponents.definitions type={:linguistic} sign={@sign} user={@user} />
    """)
  end

  defp render_notes(sign, user \\ nil) do
    assigns = %{sign: sign, user: user}

    rendered_to_string(~H"""
    <SignbankWeb.SignComponents.notes sign={@sign} user={@user} />
    """)
  end

  test "variants inherit all of their citation's definitions, including question signs" do
    html = render_definitions(load("test1b"))
    assert html =~ "A question."
  end

  test "variants do not inherit their citation's notes" do
    refute render_notes(load("test1b")) =~ "Public note."
  end

  test "the public only sees published, public note types" do
    html = render_notes(load("test1a"))
    assert html =~ "Public note."
    refute html =~ "Unpublished note."
    refute html =~ "Editor only."
  end

  test "editors see every note" do
    html = render_notes(load("test1a"), %User{role: :editor})
    assert html =~ "Public note."
    assert html =~ "Unpublished note."
    assert html =~ "Editor only."
  end

  test "notes can be added through the sign changeset" do
    sign = load("test1b")

    {:ok, sign} =
      Dictionary.update_sign(sign, %{
        "notes" => %{"0" => %{"type" => "augment", "text" => "Augmented."}},
        "notes_position" => ["0"]
      })

    assert [%Note{type: :augment, text: "Augmented.", pos: 0}] = sign.notes
  end

  test "the notes search filter never matches editor notes" do
    search = fn value ->
      %Signbank.Search{
        filters: [%Signbank.Search.Filter{field: :notes, op: :contains, value: value}]
      }
    end

    assert %{entries: [%Sign{id_gloss: "test1a"}]} =
             Dictionary.list_signs(nil, 1, search.("Public"))

    assert %{entries: []} = Dictionary.list_signs(nil, 1, search.("Editor only"))
  end
end
