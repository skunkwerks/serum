defmodule Serum.Build.FileNameHandler do
  @moduledoc false

  @spec compare(Path.t(), Path.t()) :: :gt | :eq | :lt
  def compare(filename, filename), do: :eq

  def compare(filename1, filename2) do
    [filename1, filename2]
    |> Enum.map(&normalize_date_from_filename/1)
    |> Enum.reduce(&Kernel.>/2)
    |> if(do: :gt, else: :lt)
  end

  @spec normalize_date_from_filename(Path.t()) :: String.t()
  def normalize_date_from_filename(filename) do
    filename
    |> parse_date_from_filename()
    |> case do
      %Date{} = date -> Date.to_iso8601(date)
      nil -> filename
    end
  end

  @spec parse_date_from_filename(Path.t()) :: Date.t() | nil
  def parse_date_from_filename(filename) do
    filename
    |> Path.split()
    |> List.last()
    |> do_parse_date_from_filename()
  end

  @spec do_parse_date_from_filename(String.t()) :: Date.t() | nil
  defp do_parse_date_from_filename(
         <<year::binary-size(4), ?-, month::binary-size(1), ?-, day::binary-size(1)>>
       ),
       do: parse_date_from_ymd(year, "0" <> month, "0" <> day)

  defp do_parse_date_from_filename(
         <<year::binary-size(4), ?-, month::binary-size(1), ?-, day::binary-size(2)>>
       ),
       do: parse_date_from_ymd(year, "0" <> month, day)

  defp do_parse_date_from_filename(
         <<year::binary-size(4), ?-, month::binary-size(2), ?-, day::binary-size(1)>>
       ),
       do: parse_date_from_ymd(year, month, "0" <> day)

  defp do_parse_date_from_filename(
         <<year::binary-size(4), ?-, month::binary-size(2), ?-, day::binary-size(2)>>
       ),
       do: parse_date_from_ymd(year, month, day)

  defp do_parse_date_from_filename(
         <<year::binary-size(4), ?-, month::binary-size(1), ?-, day::binary-size(1), ?-,
           _::binary>>
       ),
       do: parse_date_from_ymd(year, "0" <> month, "0" <> day)

  defp do_parse_date_from_filename(
         <<year::binary-size(4), ?-, month::binary-size(1), ?-, day::binary-size(2), ?-,
           _::binary>>
       ),
       do: parse_date_from_ymd(year, "0" <> month, day)

  defp do_parse_date_from_filename(
         <<year::binary-size(4), ?-, month::binary-size(2), ?-, day::binary-size(1), ?-,
           _::binary>>
       ),
       do: parse_date_from_ymd(year, month, "0" <> day)

  defp do_parse_date_from_filename(
         <<year::binary-size(4), ?-, month::binary-size(2), ?-, day::binary-size(2), _::binary>>
       ),
       do: parse_date_from_ymd(year, month, day)

  defp do_parse_date_from_filename(_), do: nil

  @spec parse_date_from_ymd(binary(), binary(), binary()) :: Date.t()
  defp parse_date_from_ymd(year, month, day) do
    Date.from_iso8601!(
      <<year::binary-size(4), ?-, month::binary-size(2), ?-, day::binary-size(2)>>
    )
  end
end
