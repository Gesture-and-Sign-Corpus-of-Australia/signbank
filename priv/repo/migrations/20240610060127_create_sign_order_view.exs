# excellent_migrations:safety-assured-for-this-file raw_sql_executed
defmodule Signbank.Repo.Migrations.CreateSortOrderView do
  use Ecto.Migration

  def change do
    execute(
      """
      create or replace view sign_order as with s as (select id, row_number() over (order by
        coalesce(
          array_position(
          ARRAY[ 'relaxed', 'round', 'okay',
          'point', 'hook', 'two', 'kneel', 'perth',
          'spoon', 'letter_n', 'wish', 'three',
          'mother', 'letter_m', 'four', 'spread',
          'ball', 'flat', 'thick', 'cup', 'good',
          'bad', 'gun', 'buckle', 'letter_c',
          'small', 'seven_old', 'eight', 'nine',
          'fist', 'soon', 'ten', 'write', 'salt',
          'duck', 'middle', 'rude', 'ambivalent',
          'love', 'animal', 'queer' ] :: varchar[],
          phonology ->> 'dominant_initial_handshape'
          ),
          null
        ),
        coalesce(
          array_position(
          ARRAY[ 'relaxed', 'round', 'okay',
          'point', 'hook', 'two', 'kneel', 'perth',
          'spoon', 'letter_n', 'wish', 'three',
          'mother', 'letter_m', 'four', 'spread',
          'ball', 'flat', 'thick', 'cup', 'good',
          'bad', 'gun', 'buckle', 'letter_c',
          'small', 'seven_old', 'eight', 'nine',
          'fist', 'soon', 'ten', 'write', 'salt',
          'duck', 'middle', 'rude', 'ambivalent',
          'love', 'animal', 'queer' ] :: varchar[],
          phonology ->> 'subordinate_initial_handshape'
          ),
          0
        ),
        coalesce(
          array_position(
          ARRAY[ 'top_head', 'forehead', 'temple',
          'eye', 'cheekbone', 'nose', 'whole_face',
          'ear_or_side_head', 'cheek', 'mouth_or_lips',
          'chin', 'neck', 'shoulder', 'high_neutral_space',
          'chest', 'neutral_space', 'stomach',
          'low_neutral_space', 'waist', 'below_waist',
          'upper_arm', 'elbow', 'pronated_forearm',
          'supinated_forearm', 'pronated_wrist',
          'supinated_wrist', 'palm' ] :: varchar[],
          phonology ->> 'initial_primary_location'
          ),
          null
        ),
        coalesce(  -- #############check me#######################
          array_position(
          ARRAY['up_left','up','up_right','up_away',
          'up_towards','left','away','away_left',
          'away_right','away_down','towards','down',
          'right'] :: varchar[], phonology ->> 'dominant_initial_finger_hand_orientation'
          ),
          null
        ),
        coalesce(
          array_position(
          ARRAY[ 'towards', 'left', 'away', 'up',
          'down', 'right' ] :: varchar[], phonology ->> 'dominant_initial_palm_orientation'
          ),
          null
        ),
        coalesce(
          array_position(
          ARRAY['up_left','up','up_right','up_away',
          'up_towards','left','away','away_left',
          'away_right','away_down','towards','down',
          'right'] :: varchar[], phonology ->> 'subordinate_initial_finger_hand_orientation'
          ),
          null
        ),
        coalesce(
          array_position(
          ARRAY[ 'towards', 'left', 'away', 'up',
          'down', 'right' ] :: varchar[], phonology ->> 'subordinate_initial_palm_orientation'
          ),
          null
        ),
        coalesce(
          array_position(
          ARRAY['up_left','up','up_right','up_away',
          'up_towards','left','away','away_left',
          'away_right','away_down','towards','down',
          'right'] :: varchar[], phonology ->> 'dominant_final_finger_hand_orientation'
          ),
          null
        ),
        coalesce(
          array_position(
          ARRAY[ 'palm', 'back', 'radial', 'ulnar',
          'fingertips', 'wrist', 'forearm',
          'elbow' ] :: varchar[], phonology ->> 'dominant_initial_interacting_handpart'
          ),
          null
        ),
        coalesce(
          array_position(
          ARRAY[ 'palm', 'back', 'radial', 'ulnar',
          'fingertips', 'wrist', 'forearm',
          'elbow' ] :: varchar[], phonology ->> 'subordinate_initial_interacting_handpart'
          ),
          null
        ),
        coalesce(
          array_position(
          ARRAY[ 'none', 'up', 'down', 'up_and_down',
          'left', 'right', 'side_to_side',
          'away', 'towards', 'to_and_fro' ] :: varchar[],
          phonology ->> 'movement_direction'
          ),
          0
        ),
        coalesce(
          array_position(
          ARRAY[ 'none', 'straight', 'diagonal',
          'arc', 'curved', 'wavy', 'zig_zag',
          'circular', 'spiral' ] :: varchar[],
          phonology ->> 'movement_path'
          ),
          0
        ),
        coalesce(
          array_position(
          ARRAY[false, true] :: varchar[], phonology ->> 'movement_repeated'
          ),
          0
        ),
        coalesce(
          array_position(
          ARRAY[ 'relaxed', 'round', 'okay',
          'point', 'hook', 'two', 'kneel', 'perth',
          'spoon', 'letter_n', 'wish', 'three',
          'mother', 'letter_m', 'four', 'spread',
          'ball', 'flat', 'thick', 'cup', 'good',
          'bad', 'gun', 'buckle', 'letter_c',
          'small', 'seven_old', 'eight', 'nine',
          'fist', 'soon', 'ten', 'write', 'salt',
          'duck', 'middle', 'rude', 'ambivalent',
          'love', 'animal', 'queer' ] :: varchar[],
          phonology ->> 'dominant_final_handshape'
          ),
          0
        ),
        morphology ->> 'compound_of' nulls first,
        sense_number nulls first,
        regexp_replace(
          regexp_replace(
            lower(id_gloss),
            -- remove parenthesised part if it exists
            '\\\(.*\\\)', ' ', 'i'
          ),
          '[-_]', ' ', 'ig'
        )
      ) ordernum from signs)
      select
        row_number() over (order by ordernum),
        s.id "sign_id",
        lag(s.id, 1) over (order by ordernum) "previous",
        lead(s.id, 1) over (order by ordernum) "next"
      from s;
      """,
      "drop view sign_order"
    )
  end
end
