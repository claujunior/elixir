defmodule Pf do
  def lerdados(dados) do
    try do
      stream = File.stream!(dados,[],:line)
      map_linhas =
      Stream.map(stream,&String.trim/1)
      |> Stream.map(&String.split/1)
      |> Enum.with_index(0)
      |> Enum.map(fn {linha, idx} -> {idx, List.to_tuple(linha)} end)
      |> Enum.into(%{})
      rescue
        e in File.Error ->
          IO.puts("Erro ao abrir o arquivo: #{e.reason}")
      end
    end
end
