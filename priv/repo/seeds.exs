# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Signbank.Repo.insert!(%Signbank.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

house =
  Signbank.Repo.insert!(%Signbank.Dictionary.Sign{
    id_gloss: "house1a",
    definitions: [
      %Signbank.Dictionary.Definition{
        text:
          "A building in which people live. English = house. Formal English = dwelling, residence.",
        pos: 0,
        role: :noun,
        published: true
      }
    ],
    keywords: [
      %Signbank.Dictionary.SignKeyword{
        text: "house"
      },
      %Signbank.Dictionary.SignKeyword{
        text: "home"
      }
    ],
    type: :citation,
    id_gloss_annotation: "HOUSE",
    published: true,
    morphology: %{},
    phonology: %{}
  })

Signbank.Repo.insert!(%Signbank.Dictionary.Sign{
  id_gloss: "house1b",
  type: :variant,
  id_gloss_annotation: "HOUSE",
  keywords: [
    %Signbank.Dictionary.SignKeyword{
      text: "house"
    },
    %Signbank.Dictionary.SignKeyword{
      text: "home"
    }
  ],
  published: true,
  variant_of_id: house.id,
  morphology: %{},
  phonology: %{}
})

Signbank.Repo.insert!(%Signbank.Dictionary.Sign{
  id_gloss: "dog",
  type: :citation,
  id_gloss_annotation: "DOG",
  keywords: [
    %Signbank.Dictionary.SignKeyword{
      text: "dog"
    }
  ],
  published: true,
  morphology: %{},
  phonology: %{}
})

Signbank.Repo.insert!(%Signbank.Accounts.User{
  email: "test123@gmail.com",
  role: :tech
})
