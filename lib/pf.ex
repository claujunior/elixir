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
      if String.to_integer(x) + 1< String.to_integer(posix) + String.to_integer(altura) or
           String.to_integer(y) + 1< String.to_integer(posiy) + String.to_integer(largura) or
           String.to_integer(posix) <= 0 or String.to_integer(posiy) <= 0 do
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
        if String.to_integer(x) + String.to_integer(altu) <= String.to_integer(posix) or
             String.to_integer(posix) + String.to_integer(altura) <= String.to_integer(x) or
             String.to_integer(y) + String.to_integer(larg) <= String.to_integer(posiy) or
             String.to_integer(posiy) + String.to_integer(largura) <= String.to_integer(y) do
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
    xx = String.to_integer(x)
    yy = String.to_integer(y)

    cond do
      freedom == "v" ->
        mapax1 = Map.put(mapa2, k, {Integer.to_string(xx + 1), y, xlarg, yaltu, freedom})
        mapax2 = Map.put(mapa2, k, {Integer.to_string(xx - 1), y, xlarg, yaltu, freedom})
        mapay1 = Map.put(mapa2, k, {x, Integer.to_string(yy + 1_000_000), xlarg, yaltu, freedom})
        mapay2 = Map.put(mapa2, k, {x, Integer.to_string(yy - 1_000_000), xlarg, yaltu, freedom})
        aux2valido(valido(mapax1, mapax2, mapay1, mapay2, k), [mapax1, mapax2, mapay1, mapay2])

      freedom == "h" ->
        mapax1 = Map.put(mapa2, k, {Integer.to_string(xx + 1_000_000), y, xlarg, yaltu, freedom})
        mapax2 = Map.put(mapa2, k, {Integer.to_string(xx - 1_000_000), y, xlarg, yaltu, freedom})
        mapay1 = Map.put(mapa2, k, {x, Integer.to_string(yy + 1), xlarg, yaltu, freedom})
        mapay2 = Map.put(mapa2, k, {x, Integer.to_string(yy - 1), xlarg, yaltu, freedom})
        aux2valido(valido(mapax1, mapax2, mapay1, mapay2, k), [mapax1, mapax2, mapay1, mapay2])

      freedom == "b" ->
        mapax1 = Map.put(mapa2, k, {Integer.to_string(xx + 1), y, xlarg, yaltu, freedom})
        mapax2 = Map.put(mapa2, k, {Integer.to_string(xx - 1), y, xlarg, yaltu, freedom})
        mapay1 = Map.put(mapa2, k, {x, Integer.to_string(yy + 1), xlarg, yaltu, freedom})
        mapay2 = Map.put(mapa2, k, {x, Integer.to_string(yy - 1), xlarg, yaltu, freedom})
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

    largura_tab = String.to_integer(largura)
    y = String.to_integer(y1)
    larg = String.to_integer(larg1)

    y + larg == largura_tab + 1
  end

  def bfs(start, graph_fun) do
    bfs_loop([{start, [start]}], MapSet.new(), graph_fun)
  end

  defp bfs_loop([], _visitados, _graph_fun) do
    IO.puts("Nenhum caminho encontrado.")
    :sem_caminho
  end

  defp bfs_loop([{atual, caminho} | fila], visitados, graph_fun) do
    if objetivo?(atual) do
      IO.puts("Objetivo encontrado!")
      # Retorna o percurso do início ao fim
      {:ok, Enum.reverse(caminho)}
    else
      novos_visitados = MapSet.put(visitados, atual)
      vizinhos = graph_fun.(atual)

      novos =
        for v <- vizinhos,
            not MapSet.member?(visitados, v) do
          # Guarda o caminho até o vizinho
          {v, [v | caminho]}
        end

      bfs_loop(fila ++ novos, novos_visitados, graph_fun)
    end
  end

end
