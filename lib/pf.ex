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

      validade(map_linhas)
      rescue
        e in File.Error ->
          IO.puts("Erro ao abrir o arquivo: #{e.reason}")
      end
    end

    def validade(mapa) do
  if tamanho(mapa) == :ok do
    oresto(mapa)
  else
    "Entrada invalida!"
  end
end

    def tamanho(mapa) do
      {x,y} = mapa[0]
      mapa_sem_primeiro = Map.drop(mapa, [0])
      Enum.reduce_while(mapa_sem_primeiro, :ok, fn {_, {posix,posiy,largura,altura,_}}, _ ->
        if String.to_integer(x) < String.to_integer(posix) + String.to_integer(altura) or
            String.to_integer(y) < String.to_integer(posiy) + String.to_integer(largura) do
            {:halt, :erro}
        else
          {:cont, :ok}
        end
      end)
    end

    def oresto(mapa,k) do
      {x,y,xlarg,ylarg,_} = mapa[k]
      mapa_sem_primeiro = Map.drop(mapa,[k],[0])
      Enum.reduce_while(mapa_sem_primeiro, :ok, fn {_, {posix,posiy,largura,altura,_}}, _ ->
        if String.to_integer(x) == String.to_integer(posix)  or
            String.to_integer(y) == String.to_integer(posiy) do
            {:halt, :erro}
        else
          {:cont, :ok}
        end
      end)
    end
end
