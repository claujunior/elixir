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

      {x, y} = map_linhas[0]
      mapa_sem_zero = Map.drop(map_linhas, [0])
      mapa = %{0 => {String.to_integer(x), String.to_integer(y)}}


      kkk =
        Enum.reduce(mapa_sem_zero, mapa, fn {k, {x1, y1, larg, alti, b}}, acc ->
          Map.put(
            acc,
            k,
            {String.to_integer(x1), String.to_integer(y1), String.to_integer(larg),
             String.to_integer(alti),b}
          )
        end)
      novo = Map.merge(mapa, kkk)
      validade(novo)
    rescue
      e in File.Error ->
        IO.puts("Erro ao abrir o arquivo: #{e.reason}")
    end
  end

  def validade(mapa) do
    if tamanho(mapa) == :ok do
      if aux2(aux(mapa)) == 1 do
        mapa_sem_primeiro = Map.drop(mapa, [0])

        usar =
          for {k, _} <- mapa_sem_primeiro do
            verpossibilidades(mapa, k)
          end

        if aux2(usar) == 0 do
          "Entrada invalida, letra desconhecida"
        else
          bfs(mapa, &acharvizinhos/1)
        end
      else
        "Entrada invalida, blocos sobrepostos"
      end
    else
      "Entrada invalida, blocos fora do tabuleiro"
    end
  end

  def acharvizinhos(mapa) do
    mapa_sem_primeiro = Map.drop(mapa, [0])

    usar =
      for {k, _} <- mapa_sem_primeiro do
        verpossibilidades(mapa, k)
      end

    List.flatten(usar)
  end

  def tamanho(mapa) do
    {x, y} = mapa[0]
    mapa_sem_primeiro = Map.drop(mapa, [0])

    Enum.reduce_while(mapa_sem_primeiro, :ok, fn {_, {posix, posiy, largura, altura, _}}, _ ->
      if x + 1 < posix + altura or
           y + 1 < posiy + largura or
           posix <= 0 or posiy <= 0 do
        {:halt, :erro}
      else
        {:cont, :ok}
      end
    end)
  end

  def oresto(mapa, k) do
    {x, y, larg, altu, _} = mapa[k]
    mapa_sem_primeiro = Map.drop(mapa, [0])
    mapa_sem_dois = Map.drop(mapa_sem_primeiro, [k])

    if map_size(mapa_sem_dois) == 0 do
      :xdd
    else
      Enum.reduce_while(mapa_sem_dois, :ok, fn {_, {posix, posiy, largura, altura, _}}, _ ->
        if x + altu <= posix or
             posix + altura <= x or
             y + larg <= posiy or
             posiy + largura <= y do
          {:cont, :xdd}
        else
          {:halt, :erro}
        end
      end)
    end
  end

  def aux(mapa) do
    mapa_sem_zero = Map.drop(mapa, [0])

    Enum.map(mapa_sem_zero, fn {k, _} ->
      oresto(mapa, k)
    end)
  end

  def aux2(l) do
    if Enum.member?(l, :erro) do
      0
    else
      1
    end
  end

  def proximopasso() do
    "tudo certo"
  end

  def verpossibilidades(mapa, k) do
    {x, y, xlarg, yaltu, freedom} = mapa[k]

    mapa2 = Map.drop(mapa, [k])
    xx = x
    yy = y

    cond do
      freedom == "v" ->
        mapax1 = Map.put(mapa2, k, {xx + 1, y, xlarg, yaltu, freedom})
        mapax2 = Map.put(mapa2, k, {xx - 1, y, xlarg, yaltu, freedom})
        mapay1 = Map.put(mapa2, k, {x, yy + 1_000_000, xlarg, yaltu, freedom})
        mapay2 = Map.put(mapa2, k, {x, yy - 1_000_000, xlarg, yaltu, freedom})
        aux2valido(valido(mapax1, mapax2, mapay1, mapay2, k), [mapax1, mapax2, mapay1, mapay2])

      freedom == "h" ->
        mapax1 = Map.put(mapa2, k, {xx + 1_000_000, y, xlarg, yaltu, freedom})
        mapax2 = Map.put(mapa2, k, {xx - 1_000_000, y, xlarg, yaltu, freedom})
        mapay1 = Map.put(mapa2, k, {x, yy + 1, xlarg, yaltu, freedom})
        mapay2 = Map.put(mapa2, k, {x, yy - 1, xlarg, yaltu, freedom})
        aux2valido(valido(mapax1, mapax2, mapay1, mapay2, k), [mapax1, mapax2, mapay1, mapay2])

      freedom == "b" ->
        mapax1 = Map.put(mapa2, k, {xx + 1, y, xlarg, yaltu, freedom})
        mapax2 = Map.put(mapa2, k, {xx - 1, y, xlarg, yaltu, freedom})
        mapay1 = Map.put(mapa2, k, {x, yy + 1, xlarg, yaltu, freedom})
        mapay2 = Map.put(mapa2, k, {x, yy - 1, xlarg, yaltu, freedom})
        aux2valido(valido(mapax1, mapax2, mapay1, mapay2, k), [mapax1, mapax2, mapay1, mapay2])

      true ->
        :erro
    end
  end

  def valido(mapax1, mapax2, mapay1, mapay2, k) do
    [
      auxvalido(tamanho(mapax1), oresto(mapax1, k)),
      auxvalido(tamanho(mapax2), oresto(mapax2, k)),
      auxvalido(tamanho(mapay1), oresto(mapay1, k)),
      auxvalido(tamanho(mapay2), oresto(mapay2, k))
    ]
  end

  def aux2valido([], _) do
    []
  end

  def aux2valido([a | t], [h | c]) do
    if a == :ok do
      [h | aux2valido(t, c)]
    else
      aux2valido(t, c)
    end
  end

  def auxvalido(a, k) do
    if a == :ok and k == :xdd do
      :ok
    else
      :noop
    end
  end

  defp objetivo?(mapa) do
    {largura, _} = Map.fetch!(mapa, 0)
    {_, {_, y1, larg1, _, _}} = Enum.find(mapa, fn {k, _} -> k == 1 end)

    y1 + larg1 == largura + 1
  end

  def bfs(start, graph_fun) do
  bfs_loop(:queue.from_list([{start, [start]}]), MapSet.new([start]), graph_fun)
end

defp bfs_loop(queue, visitados, graph_fun) do
  case :queue.out(queue) do
    {:empty, _} ->
      IO.puts("Nenhum caminho encontrado.")
      :sem_caminho

    {{:value, {atual, caminho}}, resto} ->
      if objetivo?(atual) do
        IO.puts("Objetivo encontrado!")
        {:ok, Enum.reverse(caminho)}
      else
        {novos_visitados, novos_nos} =
          graph_fun.(atual)
          |> Enum.reduce({visitados, []}, fn v, {vis, acc} ->
            if MapSet.member?(vis, v) do
              {vis, acc}
            else
              {MapSet.put(vis, v), [{v, [v | caminho]} | acc]}
            end
          end)

        bfs_loop(:queue.join(resto, :queue.from_list(Enum.reverse(novos_nos))), novos_visitados, graph_fun)
      end
  end
end

end
