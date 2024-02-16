defmodule QuestApiV21Web.AuthHelpers do
  def generate_jwt_and_account_response(account) do
    custom_claims = %{
      "role" => account.role,
      "id" => to_string(account.id),
      "email" => account.email
    }

    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(account, custom_claims)

    jwt_data = %{
      jwt: jwt,
      account: %{
        email: account.email,
        name: account.name,
        id: account.id,
        role: account.role
      }
    }

    {"Bearer #{jwt}", jwt_data}
  end
end
