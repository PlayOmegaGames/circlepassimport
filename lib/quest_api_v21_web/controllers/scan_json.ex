defmodule QuestApiV21Web.ScanJSON do
  alias QuestApiV21.Scans.Scan

  @doc """
  Renders a list of scans.
  """
  def index(%{scans: scans}) do
    %{data: for(scan <- scans, do: data(scan))}
  end

  @doc """
  Renders a single scan.
  """
  def show(%{scan: scan}) do
    %{data: data(scan)}
  end

  defp data(%Scan{} = scan) do
    %{
      id: scan.id,
      orgaization_id: scan.orgaization_id,
      account_id: scan.account_id,
      badge_id: scan.badge_id
    }
  end
end
