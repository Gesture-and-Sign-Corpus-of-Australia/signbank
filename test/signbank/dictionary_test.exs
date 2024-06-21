# TODO: this was from `gen.live`, look over it again
defmodule Signbank.DictionaryTest do
  use Signbank.DataCase

  alias Signbank.Dictionary

  describe "signs" do
    alias Signbank.Dictionary.Sign

    import Signbank.DictionaryFixtures

    @invalid_attrs %{}

    test "list_signs/0 returns all signs" do
      sign = sign_fixture()
      assert Dictionary.list_signs() == [sign]
    end

    test "get_sign!/1 returns the sign with given id" do
      sign = sign_fixture()
      assert Dictionary.get_sign!(sign.id) == sign
    end

    # TODO: fill in valid attrs
    test "create_sign/1 with valid data creates a sign" do
      valid_attrs = %{}

      assert {:ok, %Sign{} = sign} = Dictionary.create_sign(valid_attrs)
    end

    test "create_sign/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dictionary.create_sign(@invalid_attrs)
    end

    test "update_sign/2 with valid data updates the sign" do
      sign = sign_fixture()
      update_attrs = %{}

      assert {:ok, %Sign{} = sign} = Dictionary.update_sign(sign, update_attrs)
    end

    test "update_sign/2 with invalid data returns error changeset" do
      sign = sign_fixture()
      assert {:error, %Ecto.Changeset{}} = Dictionary.update_sign(sign, @invalid_attrs)
      assert sign == Dictionary.get_sign!(sign.id)
    end

    test "delete_sign/1 deletes the sign" do
      sign = sign_fixture()
      assert {:ok, %Sign{}} = Dictionary.delete_sign(sign)
      assert_raise Ecto.NoResultsError, fn -> Dictionary.get_sign!(sign.id) end
    end

    test "change_sign/1 returns a sign changeset" do
      sign = sign_fixture()
      assert %Ecto.Changeset{} = Dictionary.change_sign(sign)
    end
  end
end
