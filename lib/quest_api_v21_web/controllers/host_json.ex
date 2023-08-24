defmodule QuestApiV21Web.HostJSON do
  alias QuestApiV21.Hosts.Host

  @doc """
  Renders a list of hosts.
  """
  def index(%{hosts: hosts}) do
    %{data: for(host <- hosts, do: data(host))}
  end

  @doc """
  Renders a single host.
  """
  def show(%{host: host}) do
    %{data: data(host)}
  end

  defp data(%Host{} = host) do
    %{
      id: host.id,
      name: host.name,
      email: host.email,
      hashed_password: host.hashed_password
    }
  end
end
