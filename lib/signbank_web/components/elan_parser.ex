defmodule Signbank.ElanParser do
  @moduledoc """
  Parses ELAN XML files and extracts tier and annotation data.
  """

  import SweetXml

  @relevant_tiers ["RH-IDgloss", "LH-IDgloss", "FreeTransl"]

  @doc """
  Parses an ELAN XML file and returns structured data.

  Returns a map with:
  - :tiers - list of tiers with annotations
  - :duration - total duration in milliseconds

  Options:
  - :tiers - list of tier names to include (default: all)
  - :start_ms - only include annotations that overlap with this start time
  - :end_ms - only include annotations that overlap with this end time
  """
  def parse(xml_content, opts \\ []) when is_binary(xml_content) do
    tier_filter = Keyword.get(opts, :tiers, nil)
    start_ms = Keyword.get(opts, :start_ms, nil)
    end_ms = Keyword.get(opts, :end_ms, nil)

    # Parse time slots
    time_slots = parse_time_slots(xml_content)

    # Parse tiers
    tiers =
      xml_content
      |> parse_tiers(time_slots)
      |> filter_tiers(tier_filter)
      |> filter_annotations_by_range(start_ms, end_ms)
      |> Enum.reject(fn tier -> Enum.empty?(tier.annotations) end)

    # Calculate duration from the filtered annotations
    duration =
      case {start_ms, end_ms} do
        {nil, nil} ->
          time_slots |> Map.values() |> Enum.max(fn -> 0 end)

        {s, e} ->
          (e || 0) - (s || 0)
      end

    if Enum.empty?(tiers) do
      nil
    else
      %{
        tiers: tiers,
        duration: duration
      }
    end
  end

  @doc """
  Returns the list of tier names used for corpus example display.
  """
  def relevant_tiers, do: @relevant_tiers

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

  defp filter_tiers(tiers, nil), do: tiers

  defp filter_tiers(tiers, tier_names) do
    Enum.filter(tiers, fn tier -> tier.name in tier_names end)
  end

  defp filter_annotations_by_range(tiers, nil, nil), do: tiers

  defp filter_annotations_by_range(tiers, start_ms, end_ms) do
    clip_duration = (end_ms || 0) - (start_ms || 0)

    Enum.map(tiers, fn tier ->
      filtered =
        tier.annotations
        |> Enum.filter(fn anno ->
          overlaps?(anno.start, anno.end, start_ms, end_ms)
        end)
        |> Enum.map(fn anno ->
          # Shift times so the clip starts at 0, and clamp to clip boundaries
          shifted_start = max(anno.start - (start_ms || 0), 0)
          shifted_end = anno.end - (start_ms || 0)
          shifted_end = if end_ms, do: min(shifted_end, clip_duration), else: shifted_end
          %{anno | start: shifted_start, end: shifted_end}
        end)

      %{tier | annotations: filtered}
    end)
  end

  # Check if annotation [a_start, a_end] overlaps with range [r_start, r_end]
  defp overlaps?(a_start, a_end, r_start, r_end) do
    (is_nil(r_start) or a_end > r_start) and (is_nil(r_end) or a_start < r_end)
  end
end
