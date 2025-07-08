defmodule Signbank.Dictionary.SignOrder do
  @moduledoc """
  Dynamically generates sign order queries.
  """

  import Ecto.Query, warn: false

  alias Signbank.Dictionary.Sign

  def phon_enum(field, values, :nulls_first), do: phon_enum(field, values, 0)
  def phon_enum(field, values, :nulls_last), do: phon_enum(field, values, nil)

  def phon_enum(field, values, default_position) when default_position in [0, nil] do
    Ecto.Query.dynamic(
      [s],
      fragment(
        "coalesce(array_position(? :: varchar[], phonology->>?),?)",
        ^values,
        ^field,
        ^default_position
      )
    )
  end

  def order_query(order, editor?) do
    query =
      from s in Sign,
        windows: [
          sign_order: [
            order_by: ^order
          ]
        ],
        select: %{
          id: selected_as(s.id, :id),
          position:
            selected_as(
              over(
                row_number(),
                :sign_order
              ),
              :position
            ),
          previous: selected_as(s.id |> lag() |> over(:sign_order), :previous),
          next: selected_as(s.id |> lead() |> over(:sign_order), :next)
        }

    if editor? do
      query
    else
      from s in query, where: s.published
    end
  end

  def default_order do
    [
      phon_enum(
        "dominant_initial_handshape",
        [
          "relaxed",
          "round",
          "okay",
          "point",
          "hook",
          "two",
          "kneel",
          "perth",
          "spoon",
          "letter_n",
          "wish",
          "three",
          "mother",
          "letter_m",
          "four",
          "spread",
          "ball",
          "flat",
          "thick",
          "cup",
          "good",
          "bad",
          "gun",
          "buckle",
          "letter_c",
          "small",
          "seven_old",
          "eight",
          "nine",
          "fist",
          "soon",
          "ten",
          "write",
          "salt",
          "duck",
          "middle",
          "rude",
          "ambivalent",
          "love",
          "animal",
          "queer"
        ],
        :nulls_last
      ),
      phon_enum(
        "subordinate_initial_handshape",
        [
          "relaxed",
          "round",
          "okay",
          "point",
          "hook",
          "two",
          "kneel",
          "perth",
          "spoon",
          "letter_n",
          "wish",
          "three",
          "mother",
          "letter_m",
          "four",
          "spread",
          "ball",
          "flat",
          "thick",
          "cup",
          "good",
          "bad",
          "gun",
          "buckle",
          "letter_c",
          "small",
          "seven_old",
          "eight",
          "nine",
          "fist",
          "soon",
          "ten",
          "write",
          "salt",
          "duck",
          "middle",
          "rude",
          "ambivalent",
          "love",
          "animal",
          "queer"
        ],
        :nulls_first
      ),
      phon_enum(
        "initial_primary_location",
        [
          "top_head",
          "forehead",
          "temple",
          "eye",
          "cheekbone",
          "nose",
          "whole_face",
          "ear_or_side_head",
          "cheek",
          "mouth_or_lips",
          "chin",
          "neck",
          "shoulder",
          "high_neutral_space",
          "chest",
          "neutral_space",
          "stomach",
          "low_neutral_space",
          "waist",
          "below_waist",
          "upper_arm",
          "elbow",
          "pronated_forearm",
          "supinated_forearm",
          "pronated_wrist",
          "supinated_wrist",
          "palm"
        ],
        :nulls_last
      ),
      phon_enum(
        "dominant_initial_finger_hand_orientation",
        [
          "up_left",
          "up",
          "up_right",
          "up_away",
          "up_towards",
          "left",
          "away",
          "away_left",
          "away_right",
          "away_down",
          "towards",
          "down",
          "right"
        ],
        :nulls_last
      ),
      phon_enum(
        "dominant_initial_palm_orientation",
        ["towards", "left", "away", "up", "down", "right"],
        :nulls_last
      ),
      phon_enum(
        "subordinate_initial_finger_hand_orientation",
        [
          "up_left",
          "up",
          "up_right",
          "up_away",
          "up_towards",
          "left",
          "away",
          "away_left",
          "away_right",
          "away_down",
          "towards",
          "down",
          "right"
        ],
        :nulls_last
      ),
      phon_enum(
        "subordinate_initial_palm_orientation",
        ["towards", "left", "away", "up", "down", "right"],
        :nulls_last
      ),
      phon_enum(
        "dominant_final_finger_hand_orientation",
        [
          "up_left",
          "up",
          "up_right",
          "up_away",
          "up_towards",
          "left",
          "away",
          "away_left",
          "away_right",
          "away_down",
          "towards",
          "down",
          "right"
        ],
        :nulls_last
      ),
      phon_enum(
        "dominant_initial_interacting_handpart",
        [
          "palm",
          "back",
          "radial",
          "ulnar",
          "fingertips",
          "wrist",
          "forearm",
          "elbow"
        ],
        :nulls_last
      ),
      phon_enum(
        "subordinate_initial_interacting_handpart",
        [
          "palm",
          "back",
          "radial",
          "ulnar",
          "fingertips",
          "wrist",
          "forearm",
          "elbow"
        ],
        :nulls_last
      ),
      phon_enum(
        "movement_direction",
        [
          "none",
          "up",
          "down",
          "up_and_down",
          "left",
          "right",
          "side_to_side",
          "away",
          "towards",
          "to_and_fro"
        ],
        :nulls_first
      ),
      phon_enum(
        "movement_path",
        [
          "none",
          "straight",
          "diagonal",
          "arc",
          "curved",
          "wavy",
          "zig_zag",
          "circular",
          "spiral"
        ],
        :nulls_first
      ),
      phon_enum(
        "movement_repeated",
        ["false", "true"],
        :nulls_first
      ),
      phon_enum(
        "dominant_final_handshape",
        [
          "relaxed",
          "round",
          "okay",
          "point",
          "hook",
          "two",
          "kneel",
          "perth",
          "spoon",
          "letter_n",
          "wish",
          "three",
          "mother",
          "letter_m",
          "four",
          "spread",
          "ball",
          "flat",
          "thick",
          "cup",
          "good",
          "bad",
          "gun",
          "buckle",
          "letter_c",
          "small",
          "seven_old",
          "eight",
          "nine",
          "fist",
          "soon",
          "ten",
          "write",
          "salt",
          "duck",
          "middle",
          "rude",
          "ambivalent",
          "love",
          "animal",
          "queer"
        ],
        :nulls_first
      ),
      Ecto.Query.dynamic(fragment("morphology ->> 'compound_of' nulls first")),
      Ecto.Query.dynamic(fragment("sense_number nulls first")),
      # ignore the parenthesised part of ID glosses
      Ecto.Query.dynamic(
        fragment("""
        regexp_replace(
          regexp_replace(
            lower(id_gloss),
            '\\\(.*\\\)', ' ', 'i'
          ),
          '[-_]', ' ', 'ig'
        )
        """)
      )
    ]
  end
end
