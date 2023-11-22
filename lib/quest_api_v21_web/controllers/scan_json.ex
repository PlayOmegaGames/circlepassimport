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

  @doc """
  Renders an error response.
  """
  def render("error.json", %{message: message}) do
    %{errors: %{detail: message}}
  end

  defp data(%Scan{} = scan) do
    %{
      id: scan.id,
      organization_id: scan.organization_id,
      account_id: scan.account_id,
      badge_id: scan.badge_id
    }
  end
end
