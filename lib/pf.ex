defmodule Pf do
  def lerdados(dados) do
    try do
      stream = File.stream!(dados, [], :line)

      map_linhas =
        Stream.map(stream, &String.trim/1)
        |> Stream.reject(&(&1 == ""))
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
             String.to_integer(alti), b}
          )
        end)

      novo = Map.merge(mapa, kkk)
      checar_valores(String.to_integer(x), String.to_integer(y), novo)
    rescue
      e in File.Error ->
        IO.puts("Erro ao abrir o arquivo: #{e.reason}")
    end
  end

  def checar_valores(x, y, mapa) do
    cond do
      x >= 100 or y >= 100 ->
        "Entrada inválida: tamanho do tabuleiro excede o permitido"

      map_size(mapa) > 128 ->
        "Entrada inválida: blocos ultrapassam a quantidade permitida"

      true ->
        validade(mapa)
    end
  end

  def validade(mapa) do
    if tamanho(mapa) == :ok do
      if tem_erro(blocos_sobre(mapa)) == 1 do
        mapa_sem_primeiro = Map.drop(mapa, [0])

        usar =
          for {k, _} <- mapa_sem_primeiro do
            verpossibilidades(mapa, k)
          end

        if tem_erro(usar) == 0 do
          "Entrada invalida, letra desconhecida"
        else
          bfs(mapa, &acharvizinhos/1, &objetivo/1)
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

  def oresto(mapa, _) when map_size(mapa) <= 1 do
    :ok
  end
  def oresto(mapa, k) do
    case Map.get(mapa, k) do
      nil ->
        :ok

      {x, y, larg, altu, _} ->
        mapa_sem_k = Map.drop(mapa, [k])

        resultado =
          Enum.reduce_while(mapa_sem_k, :ok, fn {_, {x2, y2, larg2, altu2, _}}, _ ->
            if x + larg <= x2 or
                 x2 + larg2 <= x or
                 y + altu <= y2 or
                 y2 + altu2 <= y do
              {:cont, :ok}
            else
              {:halt, :erro}
            end
          end)

        case resultado do
          :ok -> oresto(mapa_sem_k, k + 1)
          :erro -> :erro
        end
    end
  end

  def blocos_sobre(mapa) do
    mapa_sem_zero = Map.drop(mapa, [0])

    Enum.map(mapa_sem_zero, fn {k, _} ->
      oresto(mapa_sem_zero, k)
    end)
  end

  def tem_erro(l) do
    if Enum.member?(l, :erro) do
      0
    else
      1
    end
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
        mapay1 = Map.put(mapa2, k, {x, yy + 10000, xlarg, yaltu, freedom})
        mapay2 = Map.put(mapa2, k, {x, yy - 10000, xlarg, yaltu, freedom})
        aux2valido(valido(mapax1, mapax2, mapay1, mapay2, k), [mapax1, mapax2, mapay1, mapay2])

      freedom == "h" ->
        mapax1 = Map.put(mapa2, k, {xx + 10000, y, xlarg, yaltu, freedom})
        mapax2 = Map.put(mapa2, k, {xx - 10000, y, xlarg, yaltu, freedom})
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
    mapaxx1 = Map.drop(mapax1, [0])
    mapaxx2 = Map.drop(mapax2, [0])
    mapayy1 = Map.drop(mapay1, [0])
    mapayy2 = Map.drop(mapay2, [0])

    [
      auxvalido(tamanho(mapax1), oresto1(mapaxx1, k)),
      auxvalido(tamanho(mapax2), oresto1(mapaxx2, k)),
      auxvalido(tamanho(mapay1), oresto1(mapayy1, k)),
      auxvalido(tamanho(mapay2), oresto1(mapayy2, k))
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
    if a == :ok and k == :ok do
      :ok
    else
      :noop
    end
  end

  defp objetivo(mapa) do
    {largura, _} = Map.fetch!(mapa, 0)
    {_, {_, y1, larg1, _, _}} = Enum.find(mapa, fn {k, _} -> k == 1 end)

    y1 + larg1 == largura + 1
  end


  def bfs(start, graph_fun, objetivo_fun) do
    queue = :queue.from_list([{start, [start]}])
    visitados = MapSet.new([start])

    bfs_loop(queue, visitados, graph_fun, objetivo_fun)
  end

  # Loop principal do BFS
  defp bfs_loop(queue, visitados, graph_fun, objetivo_fun) do
    case :queue.out(queue) do
      {:empty, _} ->
        :sem_caminho

      {{:value, {atual, caminho}}, resto} ->
        # Checa se o objetivo foi alcançado
        if objetivo_fun.(atual) do
          {:ok, Enum.reverse(caminho)}
        else
          # Gera vizinhos e filtra os já visitados
          {novos_visitados, novos_nos} =
            for v <- graph_fun.(atual), reduce: {visitados, []} do
              {vis, acc} ->
                if MapSet.member?(vis, v) do
                  {vis, acc}
                else
                  {MapSet.put(vis, v), [{v, [v | caminho]} | acc]}
                end
            end

          # Adiciona nós novos à fila e continua
          bfs_loop(
            :queue.join(resto, :queue.from_list(Enum.reverse(novos_nos))),
            novos_visitados,
            graph_fun,
            objetivo_fun
          )
        end
    end
  end


  def oresto1(mapa, k) do

      {x, y, larg, altu, _} = mapa[k]
        mapa_sem_k = Map.drop(mapa, [k])

          Enum.reduce_while(mapa_sem_k, :ok, fn {_, {x2, y2, larg2, altu2, _}}, _ ->
            if x + larg <= x2 or
                 x2 + larg2 <= x or
                 y + altu <= y2 or
                 y2 + altu2 <= y do
              {:cont, :ok}
            else
              {:halt, :erro}
            end
          end)
  end
end
