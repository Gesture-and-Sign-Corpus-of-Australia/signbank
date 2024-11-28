defmodule Signbank.Dictionary.Phonology do
  @moduledoc """
  The phonology of a sign, actually stored as JSON in the database
  """
  use Ecto.Schema
  import Ecto.Changeset

  @palm_orientations [
    :towards,
    :left,
    :away,
    :up,
    :down,
    :right
  ]
  @finger_hand_orientations [
    :up_left,
    :up,
    :up_right,
    :up_away,
    :up_towards,
    :left,
    :away,
    :away_left,
    :away_right,
    :away_down,
    :towards,
    :down,
    :right
  ]
  @locations [
    :top_head,
    :forehead,
    :temple,
    :eye,
    :cheekbone,
    :nose,
    :whole_face,
    :ear_or_side_head,
    :cheek,
    :mouth_or_lips,
    :chin,
    :neck,
    :shoulder,
    :high_neutral_space,
    :chest,
    :neutral_space,
    :stomach,
    :low_neutral_space,
    :waist,
    :below_waist,
    :upper_arm,
    :elbow,
    :pronated_forearm,
    :supinated_forearm,
    :pronated_wrist,
    :supinated_wrist,
    :palm
  ]
  @handshape_allophones [
    :round_flat,
    :round_flick,
    :round_e,
    :okay_flat,
    :okay_f,
    :point_d,
    :point_angled,
    :point_angled_thumb,
    :hook_bent,
    :two_angle,
    :spoon_thumb,
    :spoon_curved,
    :letter_n,
    :three_curved,
    :three_bent,
    :four_curved,
    :spread_angled,
    :ball_bent,
    :flat_b,
    :flat_angled,
    :flat_b_angled,
    :thick_open,
    :cup_thumb,
    :cup_flush,
    :good_bent,
    :bad_bent,
    :gun_bent,
    :letter_c_open,
    :small_open,
    :eight_curved,
    :fist_a,
    :soon_flick,
    :soon_closed,
    :ten_tip,
    :ten_flat,
    :ten_tip_open,
    :write_flat,
    :write_flick,
    :salt_closed,
    :salt_flick,
    :animal_closed
  ]
  @handshapes [
    :relaxed,
    :round,
    :okay,
    :point,
    :hook,
    :two,
    :kneel,
    :perth,
    :spoon,
    :letter_n,
    :wish,
    :three,
    :mother,
    :letter_m,
    :four,
    :spread,
    :ball,
    :flat,
    :thick,
    :cup,
    :good,
    :bad,
    :gun,
    :buckle,
    :letter_c,
    :small,
    :seven_old,
    :eight,
    :nine,
    :fist,
    :soon,
    :ten,
    :write,
    :salt,
    :duck,
    :middle,
    :rude,
    :ambivalent,
    :love,
    :animal,
    :queer
  ]
  @handparts [
    :palm,
    :back,
    :radial,
    :ulnar,
    :fingertips,
    :wrist,
    :forearm,
    :elbow
  ]
  @sides [
    :rightside,
    :leftside,
    :left_to_rightside,
    :right_to_leftside
  ]
  @directions [
    :none,
    :up,
    :down,
    :up_and_down,
    :left,
    :right,
    :side_to_side,
    :away,
    :towards,
    :to_and_fro
  ]
  @paths [
    :none,
    :straight,
    :diagonal,
    :arc,
    :curved,
    :wavy,
    :zig_zag,
    :circular,
    :spiral
  ]
  @repetition_types [
    :none,
    :one_same_loc,
    :two_same_loc,
    :multiple_same_loc,
    :one_diff_locs,
    :two_diff_locs,
    :multiple_diff_locs
  ]
  @handednesses [:one, :two, :double]

  def palm_orientations, do: @palm_orientations
  def finger_hand_orientations, do: @finger_hand_orientations
  def locations, do: @locations
  def handshape_allophones, do: @handshape_allophones
  def handshapes, do: @handshapes
  def handparts, do: @handparts
  def sides, do: @sides
  def directions, do: @directions
  def paths, do: @paths
  def repetition_types, do: @repetition_types
  def handednesses, do: @handednesses

  @primary_key false
  embedded_schema do
    field :dominant_initial_handshape, Ecto.Enum, values: @handshapes
    field :dominant_initial_handshape_allophone, Ecto.Enum, values: @handshape_allophones
    field :dominant_final_handshape, Ecto.Enum, values: @handshapes
    field :dominant_final_handshape_allophone, Ecto.Enum, values: @handshape_allophones
    field :dominant_initial_interacting_handpart, Ecto.Enum, values: @handparts
    field :dominant_final_interacting_handpart, Ecto.Enum, values: @handparts
    field :dominant_initial_finger_hand_orientation, Ecto.Enum, values: @finger_hand_orientations
    field :dominant_final_finger_hand_orientation, Ecto.Enum, values: @finger_hand_orientations

    field :dominant_initial_palm_orientation, Ecto.Enum, values: @palm_orientations
    field :dominant_final_palm_orientation, Ecto.Enum, values: @palm_orientations

    field :subordinate_initial_handshape, Ecto.Enum, values: @handshapes
    field :subordinate_initial_handshape_allophone, Ecto.Enum, values: @handshape_allophones
    field :subordinate_final_handshape, Ecto.Enum, values: @handshapes
    field :subordinate_final_handshape_allophone, Ecto.Enum, values: @handshape_allophones
    field :subordinate_initial_interacting_handpart, Ecto.Enum, values: @handparts
    field :subordinate_final_interacting_handpart, Ecto.Enum, values: @handparts

    field :subordinate_initial_finger_hand_orientation, Ecto.Enum,
      values: @finger_hand_orientations

    field :subordinate_final_finger_hand_orientation, Ecto.Enum, values: @finger_hand_orientations

    field :subordinate_initial_palm_orientation, Ecto.Enum, values: @palm_orientations
    field :subordinate_final_palm_orientation, Ecto.Enum, values: @palm_orientations

    field :initial_primary_location, Ecto.Enum, values: @locations
    field :final_primary_location, Ecto.Enum, values: @locations

    field :location_rightside_or_leftside, Ecto.Enum, values: @sides

    field :movement_dominant_hand_only, :boolean
    field :movement_symmetrical, :boolean
    field :movement_parallel, :boolean
    field :movement_alternating, :boolean
    field :movement_separating, :boolean
    field :movement_approaching, :boolean
    field :movement_cross, :boolean

    field :movement_direction, Ecto.Enum, values: @directions

    field :movement_path, Ecto.Enum, values: @paths

    field :movement_repeated, :boolean
    field :movement_forearm_rotation, :boolean
    field :movement_wrist_nod, :boolean
    field :movement_fingers_straighten, :boolean
    field :movement_fingers_wiggle, :boolean
    field :movement_fingers_crumble, :boolean
    field :movement_fingers_bend, :boolean

    field :change_handshape, :boolean
    field :change_open, :boolean
    field :change_close, :boolean
    field :change_orientation, :boolean

    field :contact_start, :boolean
    field :contact_end, :boolean
    field :contact_during, :boolean
    field :contact_body, :boolean
    field :contact_hands, :boolean

    field :hamnosys, :string
    field :hamnosys_variant_analysis, :string

    field :handedness, Ecto.Enum, values: @handednesses
    field :repetition_type, Ecto.Enum, values: @repetition_types
  end

  def changeset(phonology, attrs) do
    phonology
    |> cast(attrs, [
      :dominant_initial_handshape,
      :dominant_initial_handshape_allophone,
      :dominant_final_handshape,
      :dominant_final_handshape_allophone,
      :dominant_initial_interacting_handpart,
      :dominant_final_interacting_handpart,
      :dominant_initial_finger_hand_orientation,
      :dominant_final_finger_hand_orientation,
      :dominant_initial_palm_orientation,
      :dominant_final_palm_orientation,
      :subordinate_initial_handshape,
      :subordinate_initial_handshape_allophone,
      :subordinate_final_handshape,
      :subordinate_final_handshape_allophone,
      :subordinate_initial_interacting_handpart,
      :subordinate_final_interacting_handpart,
      :subordinate_initial_finger_hand_orientation,
      :subordinate_final_finger_hand_orientation,
      :subordinate_initial_palm_orientation,
      :subordinate_final_palm_orientation,
      :initial_primary_location,
      :final_primary_location,
      :location_rightside_or_leftside,
      :movement_dominant_hand_only,
      :movement_symmetrical,
      :movement_parallel,
      :movement_alternating,
      :movement_separating,
      :movement_approaching,
      :movement_cross,
      :movement_direction,
      :movement_path,
      :movement_repeated,
      :movement_forearm_rotation,
      :movement_wrist_nod,
      :movement_fingers_straighten,
      :movement_fingers_wiggle,
      :movement_fingers_crumble,
      :movement_fingers_bend,
      :change_handshape,
      :change_open,
      :change_close,
      :change_orientation,
      :contact_start,
      :contact_end,
      :contact_during,
      :contact_body,
      :contact_hands,
      :hamnosys,
      :hamnosys_variant_analysis,
      :handedness,
      :repetition_type
    ])
  end
end
