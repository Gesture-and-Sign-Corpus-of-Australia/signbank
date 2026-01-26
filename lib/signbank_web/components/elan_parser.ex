defmodule Signbank.ElanParser do
  @moduledoc """
  Parses ELAN XML files and extracts tier and annotation data.
  """

  import SweetXml

  @doc """
  Parses an ELAN XML file and returns structured data.

  Returns a map with:
  - :tiers - list of tiers with annotations
  - :duration - total duration in milliseconds
  """
  def parse(xml_content) when is_binary(xml_content) do
    # Parse time slots
    time_slots = parse_time_slots(xml_content)

    # Parse tiers
    tiers = parse_tiers(xml_content, time_slots)

    # Calculate duration (max time value)
    duration =
      time_slots
      |> Map.values()
      |> Enum.max(fn -> 0 end)

    %{
      tiers: tiers,
      duration: duration
    }
  end

  defp parse_time_slots(xml_content) do
    xml_content
    |> xpath(
      ~x"//TIME_SLOT"l,
      id: ~x"./@TIME_SLOT_ID"s,
      value: ~x"./@TIME_VALUE"i
    )
    |> Enum.into(%{}, fn slot -> {slot.id, slot.value} end)
  end

  defp parse_tiers(xml_content, time_slots) do
    xml_content
    |> xpath(
      ~x"//TIER"l,
      name: ~x"./@TIER_ID"s,
      annotations: [
        ~x"./ANNOTATION/ALIGNABLE_ANNOTATION"l,
        text: ~x"./ANNOTATION_VALUE/text()"s,
        start_ref: ~x"./@TIME_SLOT_REF1"s,
        end_ref: ~x"./@TIME_SLOT_REF2"s
      ]
    )
    |> Enum.map(fn tier ->
      %{
        name: tier.name,
        annotations:
          tier.annotations
          |> Enum.map(fn anno ->
            %{
              text: anno.text,
              start: Map.get(time_slots, anno.start_ref, 0),
              end: Map.get(time_slots, anno.end_ref, 0)
            }
          end)
          |> Enum.reject(fn anno -> anno.text == "" end)
      }
    end)
  end
end
