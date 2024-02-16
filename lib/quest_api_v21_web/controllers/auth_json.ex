defmodule QuestApiV21Web.AuthJSON do
  alias QuestApiV21Web.AccountJSON

  @moduledoc """
  JSON rendering for authentication responses.
  """

  def sign_up_success(%{jwt: jwt, account: account}) do
    %{
      data: %{
        token: jwt,
        account: AccountJSON.data(account)
      }
    }
  end

  def sign_up_error(%{error: error_message}) do
    %{
      errors: %{
        detail: error_message
      }
    }
  end

  def sign_in_success(%{jwt: jwt, account: account}) do
    %{
      data: %{
        token: jwt,
        account: AccountJSON.data(account)
      }
    }
  end

  def sign_in_error(%{error: error_message}) do
    %{
      errors: %{
        detail: error_message
      }
    }
  end
end
