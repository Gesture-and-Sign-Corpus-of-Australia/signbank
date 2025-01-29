defmodule Signbank.Dictionary.Phonology do
  @moduledoc """
  The phonology of a sign, actually stored as JSON in the database
  """
  use Ecto.Schema
  use Gettext, backend: Signbank.Gettext
  import Ecto.Changeset

  @palm_orientations [
    towards: gettext("Towards"),
    left: gettext("Left"),
    away: gettext("Away"),
    up: gettext("Up"),
    down: gettext("Down"),
    right: gettext("Right")
  ]
  @finger_hand_orientations [
    up_left: gettext("Up left"),
    up: gettext("Up"),
    up_right: gettext("Up right"),
    up_away: gettext("Up away"),
    up_towards: gettext("Up towards"),
    left: gettext("Left"),
    away: gettext("Away"),
    away_left: gettext("Away left"),
    away_right: gettext("Away right"),
    away_down: gettext("Away down"),
    towards: gettext("Towards"),
    down: gettext("Down"),
    right: gettext("Right")
  ]
  @locations [
    top_head: gettext("Top head"),
    forehead: gettext("Forehead"),
    temple: gettext("Temple"),
    eye: gettext("Eye"),
    cheekbone: gettext("Cheekbone"),
    nose: gettext("Nose"),
    whole_face: gettext("Whole face"),
    ear_or_side_head: gettext("Ear or side head"),
    cheek: gettext("Cheek"),
    mouth_or_lips: gettext("Mouth or lips"),
    chin: gettext("Chin"),
    neck: gettext("Neck"),
    shoulder: gettext("Shoulder"),
    high_neutral_space: gettext("High neutral space"),
    chest: gettext("Chest"),
    neutral_space: gettext("Neutral space"),
    stomach: gettext("Stomach"),
    low_neutral_space: gettext("Low neutral space"),
    waist: gettext("Waist"),
    below_waist: gettext("Below waist"),
    upper_arm: gettext("Upper arm"),
    elbow: gettext("Elbow"),
    pronated_forearm: gettext("Pronated forearm"),
    supinated_forearm: gettext("Supinated forearm"),
    pronated_wrist: gettext("Pronated wrist"),
    supinated_wrist: gettext("Supinated wrist")
  ]
  @handshape_allophones [
    round_flat: gettext("Round flat"),
    round_flick: gettext("Round flick"),
    round_e: gettext("Round E"),
    okay_flat: gettext("Okay flat"),
    okay_f: gettext("Okay F"),
    point_d: gettext("Point D"),
    point_angled: gettext("Point angled"),
    point_angled_thumb: gettext("Point angled thumb"),
    hook_bent: gettext("Hook bent"),
    two_angle: gettext("Two angle"),
    spoon_thumb: gettext("Spoon thumb"),
    spoon_curved: gettext("Spoon curved"),
    letter_n: gettext("Letter n"),
    three_curved: gettext("Three curved"),
    three_bent: gettext("Three bent"),
    four_curved: gettext("Four curved"),
    spread_angled: gettext("Spread angled"),
    ball_bent: gettext("Ball bent"),
    flat_b: gettext("Flat B"),
    flat_angled: gettext("Flat angled"),
    flat_b_angled: gettext("Flat B angled"),
    thick_open: gettext("Thick open"),
    cup_thumb: gettext("Cup thumb"),
    cup_flush: gettext("Cup flush"),
    good_bent: gettext("Good bent"),
    bad_bent: gettext("Bad bent"),
    gun_bent: gettext("Gun bent"),
    letter_c_open: gettext("Letter C open"),
    small_open: gettext("Small open"),
    eight_curved: gettext("Eight curved"),
    fist_a: gettext("Fist A"),
    soon_flick: gettext("Soon flick"),
    soon_closed: gettext("Soon closed"),
    ten_tip: gettext("Ten tip"),
    ten_flat: gettext("Ten flat"),
    ten_tip_open: gettext("Ten tip open"),
    write_flat: gettext("Write flat"),
    write_flick: gettext("Write flick"),
    salt_closed: gettext("Salt closed"),
    salt_flick: gettext("Salt flick"),
    animal_closed: gettext("Animal closed")
  ]
  @handshapes [
    relaxed: gettext("Relaxed"),
    round: gettext("Round"),
    okay: gettext("Okay"),
    point: gettext("Point"),
    hook: gettext("Hook"),
    two: gettext("Two"),
    kneel: gettext("Kneel"),
    perth: gettext("Perth"),
    spoon: gettext("Spoon"),
    letter_n: gettext("Letter N"),
    wish: gettext("Wish"),
    three: gettext("Three"),
    mother: gettext("Mother"),
    letter_m: gettext("Letter M"),
    four: gettext("Four"),
    spread: gettext("Spread"),
    ball: gettext("Ball"),
    flat: gettext("Flat"),
    thick: gettext("Thick"),
    cup: gettext("Cup"),
    good: gettext("Good"),
    bad: gettext("Bad"),
    gun: gettext("Gun"),
    buckle: gettext("Buckle"),
    letter_c: gettext("Letter C"),
    small: gettext("Small"),
    seven_old: gettext("Seven old"),
    eight: gettext("Eight"),
    nine: gettext("Nine"),
    fist: gettext("Fist"),
    soon: gettext("Soon"),
    ten: gettext("Ten"),
    write: gettext("Write"),
    salt: gettext("Salt"),
    duck: gettext("Duck"),
    middle: gettext("Middle"),
    rude: gettext("Rude"),
    ambivalent: gettext("Ambivalent"),
    love: gettext("Love"),
    animal: gettext("Animal"),
    queer: gettext("Queer")
  ]
  @handparts [
    palm: gettext("Palm"),
    back: gettext("Back"),
    radial: gettext("Radial"),
    ulnar: gettext("Ulnar"),
    fingertips: gettext("Fingertips"),
    wrist: gettext("Wrist"),
    # TODO: check if this should be here
    forearm: gettext("Forearm"),
    elbow: gettext("Elbow")
  ]
  @sides [
    rightside: gettext("Rightside"),
    leftside: gettext("Leftside"),
    left_to_rightside: gettext("Left-to-rightside"),
    right_to_leftside: gettext("Right-to-leftside")
  ]
  @directions [
    none: gettext("None"),
    up: gettext("Up"),
    down: gettext("Down"),
    up_and_down: gettext("Up and down"),
    left: gettext("Left"),
    right: gettext("Right"),
    side_to_side: gettext("Side-to-side"),
    away: gettext("Away"),
    towards: gettext("Towards"),
    to_and_fro: gettext("To-and-fro")
  ]
  @paths [
    none: gettext("None"),
    straight: gettext("Straight"),
    diagonal: gettext("Diagonal"),
    arc: gettext("Arc"),
    curved: gettext("Curved"),
    wavy: gettext("Wavy"),
    zig_zag: gettext("Zig-zag"),
    circular: gettext("Circular"),
    spiral: gettext("Spiral")
  ]
  @repetition_types [
    none: gettext("None"),
    one_same_loc: gettext("One same loc"),
    two_same_loc: gettext("Two same loc"),
    multiple_same_loc: gettext("Multiple same loc"),
    one_diff_locs: gettext("One diff locs"),
    two_diff_locs: gettext("Two diff locs"),
    multiple_diff_locs: gettext("Multiple diff locs")
  ]
  @handednesses [
    one: gettext("one"),
    two: gettext("two"),
    double: gettext("double")
  ]

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
