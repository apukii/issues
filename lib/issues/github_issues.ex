defmodule Issues.GithubIssues do
  require Logger
  @user_agent [ {"User-agent", "Elixir apuki@apuki.com"} ]
  def fetch(user, project) do
    Logger.info("Fetching #{user}'s project #{project}")
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  # 컴파일 시점에 값을 가져오기 위해 모듈 속성을 사용한다.
  @github_url Application.get_env(:issues, :github_url)

  def issues_url(user, project) do
    # "https://api.github.com/repos/#{user}/#{project}/issues"
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  # def handle_response({ :ok, %{status_code: 200, body: body} }) do
  #   {:ok, body}
  # end

  # def handle_response({ _, %{status_code: _, body: body} }) do
  #   {:error, body}
  # end
  def handle_response({ _, %{status_code: status_code, body: body} }) do
    Logger.info("Get response: status code=#{status_code}")
    Logger.debug(fn -> inspect(body) end)
    {
      status_code |> check_for_error(),
      body        |> Poison.Parser.parse!(%{})
    }
  end
  defp check_for_error(200), do: :ok
  defp check_for_error(_), do: :error
end
