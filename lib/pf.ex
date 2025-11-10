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
    if Enum.member?(l, :erro) do
      0
    else
      1
    end
  end

  def proximopasso() do
    "tudo certo"
  end

  # Função BFS (Breadth-First Search) para percorrer o grafo
  # paths: mapa de vértices para a camada em que foram encontrados
  # graph: mapa de adjacências {nó => vizinhos}
  # [] lista vazia de nós atuais
  # neighbors: lista de próximos vizinhos a visitar
  # layer: profundidade atual da BFS

  # Caso base: nenhum nó para processar e nenhum vizinho restante
  defp bfs(paths, _, [], [], _), do: paths

  # Se não houver nós atuais, mas houver vizinhos para explorar, passa para a próxima camada
  defp bfs(paths, graph, [], neighbors, layer) do
    bfs(paths, graph, neighbors, [], layer + 1)
  end

  # Se o nó já está no mapa de caminhos, apenas continua com o restante da lista
  defp bfs(paths, graph, [u | tail], neighbors, layer) when is_map_key(paths, u) do
    bfs(paths, graph, tail, neighbors, layer)
  end

  # Caso normal: nó ainda não visitado, adiciona ao mapa com a camada e continua
  defp bfs(paths, graph, [u | tail], neighbors, layer) do
    Map.put_new(paths, u, layer)
    |> bfs(graph, tail, MapSet.to_list(graph[u]) ++ neighbors, layer)
  end

  # Função para expandir os caminhos calculados
  # paths: mapa de vértices para camadas
  # n: índice atual
  # s: índice máximo ou referência

  # Caso base: n = 0
  defp expand_paths(_, 0, _), do: []

  # Ajusta o índice se n = s
  defp expand_paths(paths, s, s), do: expand_paths(paths, s - 1, s)

  # Se o nó está no mapa, multiplica a camada por 6
  defp expand_paths(paths, n, s) when is_map_key(paths, n) do
    [paths[n] * 6] ++ expand_paths(paths, n - 1, s)
  end

  # Caso contrário, adiciona -1
  defp expand_paths(paths, n, s) do
    [-1] ++ expand_paths(paths, n - 1, s)
  end
end
