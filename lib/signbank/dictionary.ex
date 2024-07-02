defmodule Signbank.Dictionary do
  @moduledoc """
  The Dictionary context.
  """

  import Ecto.Query, warn: false
  alias Signbank.Repo

  alias Signbank.Dictionary.Sign

  @southern_states [:victoria, :new_south_wales, :tasmania]
  @northern_states [:queensland, :western_australia]
  @default_order [
    :australia_wide,
    :no_region,
    :southern_dialect,
    :northern_dialect,
    :victoria,
    :new_south_wales,
    :queensland,
    :western_australia,
    :tasmania
  ]
  @southern_order [
                    :australia_wide,
                    :no_region,
                    :southern_dialect,
                    :northern_dialect
                  ] ++
                    @southern_states ++
                    @northern_states
  @northern_order [
                    :australia_wide,
                    :no_region,
                    :northern_dialect,
                    :southern_dialect
                  ] ++
                    @northern_states ++
                    @southern_states

  defp sort_order(:northern_dialect), do: @northern_order
  defp sort_order(:southern_dialect), do: @southern_order
  defp sort_order(_), do: @default_order

  @doc """
  Returns a paginated list of signs.

  ## Examples

      iex> list_signs(1)
      [%Sign{}, ...]
  """
  def list_signs do
    list_signs(1)
  end

  def list_signs(page) do
    Repo.paginate(
      from(s in Sign, order_by: [asc: s.id_gloss, asc: s.id]),
      %{page: page}
    )
  end

  @doc """
  Gets a single sign.

  Raises `Ecto.NoResultsError` if the Sign does not exist.

  ## Examples

      iex> get_sign!(123)
      %Sign{}

      iex> get_sign!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sign!(id), do: Repo.get!(Sign, id)

  @doc """
  Returns a sign with the given `id_gloss`.

  ## Examples

      iex> get_sign_by_id_gloss!("house1a")
      %Sign{}

  """
  def get_sign_by_id_gloss!(id_gloss),
    do:
      Repo.get_by!(
        from(s in Sign,
          preload: [
            citation: [definitions: []],
            definitions: [],
            variants: [videos: [], regions: []],
            regions: [],
            videos: [],
            active_video: []
          ]
        ),
        id_gloss: id_gloss
      )

  @doc """
  Returns a sign with the given `id_gloss`. It only returns citation entries.

  ## Examples

      iex> get_sign_by_keyword!("house")
      {:ok, [["house", "house1a"]]}

      iex> get_sign_by_keyword!("hou")
      {:ok, [["hour", "hour_clockface"], ["house", "house1a"]]}

  """
  def get_sign_by_keyword!(keyword, region_preference \\ :australia_wide) do
    region_sorter = fn %Sign{regions: regions} ->
      Enum.find_index(sort_order(region_preference), fn x ->
        Atom.to_string(x) == Enum.at(regions, 0)
        # TODO: deal with signs with multiple regions
      end)
    end

    case Repo.all(
           from(s in Sign,
             preload: [
               citation: [definitions: []],
               definitions: [],
               variants: [videos: [], regions: []],
               regions: [],
               videos: [],
               active_video: []
             ],
             where:
               fragment("?=any(keywords::citext[])", ^keyword) and
                 s.type == :citation
           )
         ) do
      [] -> {:err, "No signs with keyword #{keyword} found."}
      results -> {:ok, results |> Enum.sort_by(region_sorter, :asc)}
    end
  end

  @doc """
  Returns [[keyword, id_gloss of first match (by region sort)]..]

  If the search is not ambiguous (i.e., there is an exact keyword match and there
  are no other keywords that start with `query`), then it only returns that one match.
  """
  def fuzzy_find_keyword(query, region_preference \\ :australia_wide) do
    region_sorter = fn [_id_gloss, _kw, regions, _published] ->
      Enum.find_index(sort_order(region_preference), fn x ->
        Atom.to_string(x) == Enum.at(regions, 0)
        # TODO: deal with signs with multiple regions
      end)
    end

    results =
      Repo.query(
        """
        select
          id_gloss,
          kw,
          array(select region from sign_regions sr where sr.sign_id = s2.id) regions,
          published
        from
        (select id, unnest(keywords) as kw, id_gloss, "type", published from signs where "type" = 'citation') s2
        where starts_with(lower(kw),lower($1));
        """,
        [query]
      )

    case results do
      {:ok, %Postgrex.Result{rows: rows}} ->
        results =
          rows
          |> Enum.group_by(fn [_id_gloss, kw, _regions, published] -> kw end)
          |> Enum.map(fn {kw, matches} ->
            similarity = matches |> Enum.at(0) |> Enum.at(3)

            [
              kw,
              matches
              |> Enum.sort_by(region_sorter, :asc)
              |> Enum.at(0)
              |> Enum.at(0),
              similarity
            ]
          end)

        exact_match? = fn [_, _, similarity] -> similarity == 1.0 end

        {:ok,
         if(Enum.count(results, exact_match?) == 1,
           do: results |> Enum.filter(exact_match?),
           else: results
         )}

      _ ->
        {:err, "No results found."}
    end
  end

  @doc """
  Finds next and previous Signs in predefined sorting order.
  """
  def get_prev_next_signs!(%Sign{id: id}) do
    Repo.one!(
      from so in "sign_order",
        left_join: p in Sign,
        on: [id: so.previous],
        left_join: n in Sign,
        on: [id: so.next],
        where: so.sign_id == ^id,
        select: %{previous: p, next: n}
    )
  end

  @doc """
  Returns only the fields relevant for sorting for signs with the given ID glosses.
  """
  def debug_sign_order!(id_gloss) when is_binary(id_gloss), do: debug_sign_order!([id_gloss])

  def debug_sign_order!(id_glosses)
      when is_list(id_glosses) do
    Repo.all(
      from s in Sign,
        where: s.id_gloss in ^id_glosses,
        select: %{
          a_subordinate_initial_handshape:
            fragment("phonology->>?", "dominant_initial_handshape"),
          b_subordinate_initial_handshape:
            fragment("phonology->>?", "subordinate_initial_handshape"),
          c_dominant_initial_finger_hand_orientation:
            fragment("phonology->>?", "dominant_initial_finger_hand_orientation"),
          d_subordinate_initial_handshape:
            fragment("phonology->>?", "subordinate_initial_handshape"),
          e_initial_primary_location: fragment("phonology->>?", "initial_primary_location"),
          f_dominant_initial_palm_orientation:
            fragment("phonology->>?", "dominant_initial_palm_orientation"),
          g_subordinate_initial_finger_hand_orientation:
            fragment("phonology->>?", "subordinate_initial_finger_hand_orientation"),
          h_subordinate_initial_palm_orientation:
            fragment("phonology->>?", "subordinate_initial_palm_orientation"),
          i_dominant_final_finger_hand_orientation:
            fragment("phonology->>?", "dominant_final_finger_hand_orientation"),
          j_dominant_initial_interacting_handpart:
            fragment("phonology->>?", "dominant_initial_interacting_handpart"),
          k_subordinate_initial_interacting_handpart:
            fragment("phonology->>?", "subordinate_initial_interacting_handpart"),
          k_movement_direction: fragment("phonology->>?", "movement_direction"),
          l_movement_path: fragment("phonology->>?", "movement_path"),
          m_movement_repeated: fragment("phonology->>?", "movement_repeated"),
          n_dominant_final_handshape: fragment("phonology->>?", "dominant_final_handshape"),
          o_compound_of: fragment("morphology->>?", "compound_of"),
          p_sense_number: s.sense_number,
          q_id_gloss: s.id_gloss
        }
    )
  end

  @doc """
  Creates a sign.

  ## Examples

      iex> create_sign(%{field: value})
      {:ok, %Sign{}}

      iex> create_sign(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sign(attrs \\ %{}) do
    %Sign{}
    |> Sign.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sign.

  ## Examples

      iex> update_sign(sign, %{field: new_value})
      {:ok, %Sign{}}

      iex> update_sign(sign, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sign(%Sign{} = sign, attrs) do
    sign
    |> Sign.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sign.

  ## Examples

      iex> delete_sign(sign)
      {:ok, %Sign{}}

      iex> delete_sign(sign)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sign(%Sign{} = sign) do
    Repo.delete(sign)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sign changes.

  ## Examples

      iex> change_sign(sign)
      %Ecto.Changeset{data: %Sign{}}

  """
  def change_sign(%Sign{} = sign, attrs \\ %{}) do
    Sign.changeset(sign, attrs)
  end
end
