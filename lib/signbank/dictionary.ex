# credo:disable-for-this-file Credo.Check.Refactor.VariableRebinding
defmodule Signbank.Dictionary do
  @moduledoc """
  The Dictionary context.
  """

  import Ecto.Query, warn: false

  alias Signbank.Accounts.User
  alias Signbank.Dictionary.Sign
  alias Signbank.Dictionary.SignVideo
  alias Signbank.Repo

  @default_order [
    :australia_wide,
    :southern_dialect,
    :northern_dialect,
    :victoria,
    :new_south_wales,
    :queensland,
    :western_australia,
    :south_australia,
    :tasmania,
    :no_region
  ]

  defp sort_order, do: @default_order

  # sub_field is for fields inside a JSON column
  def query_from_filter(
        %Signbank.Search.Filter{
          field: field,
          sub_field: sub_field,
          op: :equal_to,
          value: val
        },
        queryable
      )
      when is_binary(sub_field) do
    # HACK: this is ugly but its the best I got right now
    if val == "unspecified" do
      dynamic([s], ^queryable and fragment("?::json->>? is null", ^field, ^sub_field))
    else
      dynamic([s], ^queryable and fragment("?->>? = ?", field(s, ^field), ^sub_field, ^val))
    end
  end

  def query_from_filter(
        %Signbank.Search.Filter{
          field: field,
          op: :equal_to,
          value: val
        },
        queryable
      ) do
    # HACK: this is ugly but its the best I got right now
    if val == "unspecified" do
      dynamic([s], ^queryable and is_nil(field s, ^field))
    else
      dynamic([s], ^queryable and field(s, ^field) == ^val)
    end
  end

  def query_from_filter(
        %Signbank.Search.Filter{
          field: field,
          op: :contains,
          value: val
        },
        queryable
      ) do
    dynamic([s], ^queryable and like(field(s, ^field), ^"%#{val}%"))
  end

  def query_from_filter(
        %Signbank.Search.Filter{
          field: field,
          op: :starts_with,
          value: val
        },
        queryable
      ) do
    dynamic([s], ^queryable and like(field(s, ^field), ^"#{val}%"))
  end

  def query_from_filter(
        %Signbank.Search.Filter{
          field: field,
          op: :regex,
          value: val
        },
        queryable
      ) do
    dynamic([s], ^queryable and fragment("? ~ ?", field(s, ^field), ^val))
  end

  def query_from_filter(
        %Signbank.Search.Filter{
          field: field,
          op: :greater_than,
          value: val
        },
        queryable
      ) do
    dynamic([s], ^queryable and field(s, ^field) > ^val)
  end

  def query_from_filter(
        %Signbank.Search.Filter{
          field: field,
          op: :less_than,
          value: val
        },
        queryable
      ) do
    dynamic([s], ^queryable and field(s, ^field) < ^val)
  end

  def query_from_filter(_, queryable) do
    dynamic([s], ^queryable)
  end

  @doc """
  Returns a paginated list of signs.

  ## Examples

      iex> list_signs(1)
      [%Sign{}, ...]
  """
  def list_signs(
        user \\ %User{},
        page \\ 1,
        %Signbank.Search{filters: filters} \\ %Signbank.Search{}
      ) do
    base_query =
      from s in Sign,
        order_by: [
          fragment("lower(?) ASC", s.id_gloss)
        ]

    query =
      if is_nil(user) or Map.get(user, :role) not in [:tech, :editor] do
        from s in base_query, where: s.published == true
      else
        base_query
      end

    where =
      Enum.reduce(
        filters,
        dynamic(true),
        &query_from_filter/2
      )

    Repo.paginate(
      from(s in query,
        where: ^where
      ),
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

      iex> get_sign_by_id_gloss("house1a")
      %Sign{}

  """
  def get_sign_by_id_gloss(id_gloss, current_scope \\ nil) do
    query =
      from s in Sign,
        preload: [
          citation: [definitions: [], variants: []],
          definitions: [],
          variants: [videos: [], regions: []],
          semantic_categories: [],
          regions: [],
          videos: [],
          active_video: [],
          relations: [],
          suggested_signs: [],
          active_video: []
        ],
        where: s.id_gloss == ^id_gloss

    Repo.one(
      case is_struct(current_scope) and current_scope.user do
        %User{role: role} when role in [:tech, :editor] ->
          query

        _ ->
          from s in query, where: s.published == true
      end
    )
  end

  @doc """
  Results list of signs filtered by phonological feature and keyword
  """
  def get_sign_by_phon_feature!(user \\ %User{}, params) do
    query =
      from s in Sign,
        preload: [
          citation: [definitions: [], variants: []],
          definitions: [],
          variants: [videos: [], regions: []],
          regions: [],
          videos: [],
          active_video: [],
          suggested_signs: []
        ]

    query =
      if handshape = Map.get(params, "hs") do
        from s in query,
          where: fragment("phonology->>? = ?", "dominant_initial_handshape", ^handshape)
      else
        query
      end

    query =
      if location = Map.get(params, "loc") do
        from s in query,
          where: fragment("phonology->>? = ?", "initial_primary_location", ^location)
      else
        query
      end

    query =
      if q = Map.get(params, "q") do
        from s in query,
          where:
            fragment(
              "exists (select * from (select unnest(keywords::citext[])) foo(keyword) where foo.keyword like ?)",
              ^"#{q}%"
            )
      else
        query
      end

    Repo.all(
      if is_nil(user) or Map.get(user, :role) not in [:tech, :editor] do
        from s in query, where: s.published == true
      else
        query
      end
    )
  end

  @doc """
  Returns a sign with the given `id_gloss`. It only returns citation entries.

  ## Examples

      iex> get_sign_by_keyword!("house")
      {:ok, [["house", "house1a"]]}

      iex> get_sign_by_keyword!("hou")
      {:ok, [["hour", "hour_clockface"], ["house", "house1a"]]}

  """
  def get_sign_by_keyword!(keyword) do
    region_sorter = fn %Sign{regions: regions} ->
      Enum.find_index(sort_order(), fn x ->
        Atom.to_string(x) == Enum.at(regions, 0)
        # TODO: deal with signs with multiple regions
      end)
    end

    case Repo.all(
           from s in Sign,
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
         ) do
      [] -> {:err, "No signs with keyword #{keyword} found."}
      results -> {:ok, Enum.sort_by(results, region_sorter, :asc)}
    end
  end

  @doc """
  Returns [[keyword, id_gloss of first match (by region sort)]..]

  If the search is not ambiguous (i.e., there is an exact keyword match and there
  are no other keywords that start with `query`), then it only returns that one match.
  """
  def fuzzy_find_keyword(query, current_scope \\ nil) do
    region_sorter = fn [_id_gloss, _kw, regions, _published] ->
      Enum.find_index(sort_order(), fn x ->
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

    visible? = fn [_id_gloss, _kw, _regions, published?] ->
      published? or current_scope.user.role in [:tech, :editor]
    end

    case results do
      {:ok, %Postgrex.Result{rows: rows}} ->
        results =
          rows
          |> Enum.filter(visible?)
          |> Enum.group_by(fn [_id_gloss, kw, _regions, _published?] -> kw end)
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
           do: Enum.filter(results, exact_match?),
           else: results
         )}

      _ ->
        {:err, []}
    end
  end

  @doc """
  Finds next and previous Signs in predefined sorting order.
  """
  def get_prev_next_signs!(%Sign{id: id}, current_scope) do
    query =
      Signbank.Dictionary.SignOrder.order_query(
        Signbank.Dictionary.SignOrder.default_order(),
        case is_struct(current_scope) and current_scope.user do
          %User{role: role} when role in [:tech, :editor] -> true
          _ -> false
        end
      )

    case Repo.one(
           from so in subquery(query),
             left_join: p in Sign,
             on: [id: so.previous],
             left_join: n in Sign,
             on: [id: so.next],
             select: %{previous: p, next: n, position: so.position},
             where: so.id == ^id
         ) do
      nil -> %{previous: nil, next: nil, position: nil}
      record -> record
    end
  end

  @doc """
  Counts the number of signs in the dictionary.
  """
  def count_signs do
    Repo.aggregate(from(s in Sign, where: s.published == true), :count)
  end

  def count_signs(%User{role: role}) when role in [:tech, :editor] do
    Repo.aggregate(from(s in Sign), :count)
  end

  def count_signs(_) do
    count_signs()
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

  def create_video(attrs \\ %{}) do
    %SignVideo{}
    |> SignVideo.changeset(attrs)
    |> Repo.insert()
  end

  def set_active_video(%Sign{} = sign, id) do
    sign
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:active_video_id, id)
    |> Repo.update()
    |> case do
      {:ok, sign} -> {:ok, Repo.preload(sign, :active_video)}
      error -> error
    end
  end

  def update_regions(_, nil), do: []
  def update_regions(%{regions: nil}, updated_regions), do: update_regions([], updated_regions)

  def update_regions(sign, updated_regions) do
    updated_regions
    |> Enum.map(fn
      "" ->
        nil

      region_name ->
        Enum.find(
          sign.regions,
          %{sign_id: sign.id, region: region_name},
          &(&1.region == region_name)
        )
    end)
    |> Enum.filter(fn x -> x != nil end)
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
