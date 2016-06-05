defmodule Spellcheck do

  def main(args) do
    args
      |> parametrize
      |> checkOnMashape
      |> parseMashapeResponse
      |> formatOutput
      |> IO.puts
  end

  defp parametrize(words) do
    words |> Enum.join("+")
  end

  defp checkOnMashape(param) do
    HTTPoison.get!(
      "https://montanaflynn-spellcheck.p.mashape.com/check/?text=#{param}",
      [
        {"X-Mashape-Key", Application.get_env(:mashape, :key)},
        {"Accept", "application/json"}
      ]
    )
  end

  defp parseMashapeResponse(resp) do
    %HTTPoison.Response{body: body} = resp
    body |> Poison.Parser.parse!
  end

  def formatOutput(parsedResponse) do
    Enum.map(parsedResponse["corrections"], fn {word, suggestions} ->
      formatted_suggestions = suggestions
        |> Enum.map(
          fn s ->
            [IO.ANSI.cyan, s, "\t\t", IO.ANSI.reset, "http://www.dictionary.com/browse/", s]
          end)
        |> Enum.join("\n\t")
      [IO.ANSI.red, word, ":\n\t", formatted_suggestions]
    end)
    |> Enum.concat([IO.ANSI.cyan, "Suggestion: #{[IO.ANSI.reset, parsedResponse["suggestion"]]}\n"])
    |> Enum.join("\n")
  end
end
