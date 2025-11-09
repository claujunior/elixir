defmodule Pf do
  def lerdados(dados) do
    try do
      stream = File.stream!(dados, [], :line)

      map_linhas =
        Stream.map(stream, &String.trim/1)
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
      if aux2(aux(mapa))==1 do
        proximopasso()
      else
        "Entrada invalida, blocos sobrepostos"
      end
    else
      "Entrada invalida, blocos fora do tabuleiro"
    end
  end

  def tamanho(mapa) do
    {x, y} = mapa[0]
    mapa_sem_primeiro = Map.drop(mapa, [0])

    Enum.reduce_while(mapa_sem_primeiro, :ok, fn {_, {posix, posiy, largura, altura, _}}, _ ->
      if String.to_integer(x) < String.to_integer(posix) + String.to_integer(altura) or
           String.to_integer(y) < String.to_integer(posiy) + String.to_integer(largura) do
        {:halt, :erro}
      else
        {:cont, :ok}
      end
    end)
  end

  def oresto(mapa, k) do
    {x, y, xlarg, yaltu, _} = mapa[k]
    mapa_sem_primeiro = Map.drop(mapa, [0])
    mapa_sem_dois = Map.drop(mapa_sem_primeiro, [k])

    Enum.reduce_while(mapa_sem_dois, :ok, fn {_, {posix, posiy, largura, altura, _}}, _ ->
      if String.to_integer(x) + String.to_integer(xlarg) <= String.to_integer(posix) or
           String.to_integer(posix) + String.to_integer(largura) <= String.to_integer(x) or
           String.to_integer(y) + String.to_integer(yaltu) <= String.to_integer(posiy) or
           String.to_integer(posiy) + String.to_integer(altura) <= String.to_integer(y) do
        {:cont, :xdd}
      else
        {:halt, :erro}
      end
    end)
  end

  def aux(mapa) do
    mapa_sem_zero = Map.drop(mapa, [0])

    Enum.map(mapa_sem_zero, fn {k, _} ->
      oresto(mapa, k)
    end)
  end

  def aux2(l) do
      if Enum.member?(l,:erro) do
        0
      else
        1
      end
  end
  def proximopasso() do
    "tudo certo"
  end
end
