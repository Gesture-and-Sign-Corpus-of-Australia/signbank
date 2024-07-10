defmodule Signbank.Dictionary.PreparedQueries do
  @moduledoc """
  Queries for lexicographers to diagnose issues.
  """

  import Ecto.Query, warn: false
  alias Signbank.Repo

  alias Signbank.Dictionary.Sign

  def keyword_mismatch() do
    contains_keyword? = fn
      keyword ->
        fn definition ->
          definition.text
          |> String.downcase()
          |> String.contains?(String.replace(String.downcase(keyword), ~r"\s?\(.*\)", ""))
        end
    end

    build_csv_row = fn
      s -> [s.id_gloss]
    end

    file = File.open!("test.csv", [:write, :utf8])

    Repo.all(from s in Sign, preload: [:definitions, citation: [:definitions]])
    |> Enum.filter(fn
      %{citation: nil} = s ->
        defs = s.definitions
        not Enum.any?(s.keywords, &Enum.any?(defs, contains_keyword?.(&1)))

      %{citation: _} = s ->
        defs = Enum.concat(s.definitions, Map.get(s.citation, :definitions, []))
        not Enum.any?(s.keywords, &Enum.any?(defs, contains_keyword?.(&1)))
    end)
    |> Enum.map(build_csv_row)
    |> CSV.encode()
    |> Enum.each(&IO.write(file, &1))
  end
end
