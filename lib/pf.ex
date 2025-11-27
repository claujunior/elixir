defmodule Pf do
  @moduledoc """
  Módulo responsável por ler um arquivo de entrada contendo um tabuleiro e seus blocos,
  validar a configuração inicial, gerar todos os movimentos possíveis e resolver o
  quebra-cabeça utilizando BFS (Busca em Largura).

  ## Funcionalidades principais

    * Leitura do arquivo e parse da entrada.
    * Validação dos tamanhos e limites do tabuleiro.
    * Detecção de sobreposição entre blocos.
    * Geração de movimentos válidos (vertical, horizontal e bloco livre).
    * Busca BFS para encontrar sequência mínima de movimentos.
    * Geração de passos textuais e compactação de passos repetidos.
  """

  @doc """
  Lê e processa o arquivo de entrada contendo o tabuleiro e os blocos.

  Retorna:

    * Estrutura de dados do tabuleiro caso esteja correto.
    * Mensagem de erro caso a entrada seja inválida.

  """
  def ler_dados(caminho_arquivo) do
    try do
      stream = File.stream!(caminho_arquivo, [], :line)

      linhas_map =
        Stream.map(stream, &String.trim/1)
        |> Stream.reject(&(&1 == ""))
        |> Stream.map(&String.split/1)
        |> Enum.with_index(0)
        |> Enum.map(fn {linha, idx} -> {idx, List.to_tuple(linha)} end)
        |> Enum.into(%{})

      {x, y} = linhas_map[0]
      mapa_sem_zero = Map.drop(linhas_map, [0])
      mapa = %{0 => {String.to_integer(x), String.to_integer(y)}}

      blocos_processados =
        Enum.reduce(mapa_sem_zero, mapa, fn {k, {x1, y1, larg, alti, b}}, acc ->
          Map.put(
            acc,
            k,
            {String.to_integer(x1), String.to_integer(y1), String.to_integer(larg),
             String.to_integer(alti), b}
          )
        end)

      mapa_final = Map.merge(mapa, blocos_processados)
      checar_valores(String.to_integer(x), String.to_integer(y), mapa_final)
    rescue
      e in File.Error ->
        IO.puts("Erro ao abrir o arquivo: #{e.reason}")
    end
  end

  @doc """
  Faz checagens básicas do tabuleiro antes de validar blocos:

    * Tabuleiro maior que o permitido (100×100).
    * Quantidade máxima de blocos (128).
  """
  def checar_valores(largura_tab, altura_tab, mapa) do
    cond do
      largura_tab >= 100 or altura_tab >= 100 ->
        "Entrada inválida: tamanho do tabuleiro excede o permitido"

      map_size(mapa) > 128 ->
        "Entrada inválida: blocos ultrapassam a quantidade permitida"

      true ->
        validar_mapa(mapa)
    end
  end

  @doc """
  Realiza todas as validações do tabuleiro:

    * Blocos dentro da área válida.
    * Sem sobreposições.
    * Letras dos blocos reconhecidas (`h`, `v`, `b`).
  """
  def validar_mapa(mapa) do
    if tamanho_valido(mapa) == :ok do
      if existe_sobreposicao(blocos_sobrepostos(mapa)) == 1 do
        mapa_sem_tabuleiro = Map.drop(mapa, [0])

        possibilidades =
          for {k, _} <- mapa_sem_tabuleiro do
            gerar_movimentos(mapa, k)
          end

        if existe_sobreposicao(possibilidades) == 0 do
          "Entrada invalida, letra desconhecida"
        else
          bfs(mapa, &achar_vizinhos/1, &objetivo_alcancado?/1)
          |> gerar_lista_de_passos()
          |> compactar_passos()
          |> kk()
        end
      else
        "Entrada invalida, blocos sobrepostos"
      end
    else
      "Entrada invalida, blocos fora do tabuleiro"
    end
  end

  @doc """
  Gera todos os vizinhos (estados alcançáveis) a partir de um mapa.
  """
  def achar_vizinhos(mapa) do
    mapa_sem_tabuleiro = Map.drop(mapa, [0])

    movimentos =
      for {k, _} <- mapa_sem_tabuleiro do
        gerar_movimentos(mapa, k)
      end

    List.flatten(movimentos)
  end

  @doc """
  Confere se cada bloco está dentro dos limites do tabuleiro.
  """
  def tamanho_valido(mapa) do
    {larg, alt} = mapa[0]
    mapa_sem_tabuleiro = Map.drop(mapa, [0])

    Enum.reduce_while(mapa_sem_tabuleiro, :ok, fn {_, {x, y, largura, altura, _}}, _ ->
      if larg + 1 < x + altura or alt + 1 < y + largura or x <= 0 or y <= 0 do
        {:halt, :erro}
      else
        {:cont, :ok}
      end
    end)
  end

  @doc """
  Verifica sobreposição entre todos os blocos, chamando `restante/2` para cada bloco.
  """
  def restante(mapa, _) when map_size(mapa) <= 1, do: :ok
  def restante(mapa, k) do
    case Map.get(mapa, k) do
      nil -> :ok
      {x, y, larg, alt, _} ->
        mapa_sem_k = Map.drop(mapa, [k])

        resultado =
          Enum.reduce_while(mapa_sem_k, :ok, fn {_, {x2, y2, larg2, alt2, _}}, _ ->
            if x + larg <= x2 or x2 + larg2 <= x or y + alt <= y2 or y2 + alt2 <= y do
              {:cont, :ok}
            else
              {:halt, :erro}
            end
          end)

        case resultado do
          :ok -> restante(mapa_sem_k, k + 1)
          :erro -> :erro
        end
    end
  end

  @doc """
  Aplica `restante/2` para todos os blocos e retorna lista de `:ok` ou `:erro`.
  """
  def blocos_sobrepostos(mapa) do
    mapa_sem_tabuleiro = Map.drop(mapa, [0])
    Enum.map(mapa_sem_tabuleiro, fn {k, _} -> restante(mapa_sem_tabuleiro, k) end)
  end

  @doc """
  Retorna 0 se houver qualquer sobreposição, 1 caso contrário.
  """
  def existe_sobreposicao(lista) do
    if Enum.member?(lista, :erro), do: 0, else: 1
  end

  @doc """
  Gera movimentos válidos para um bloco específico.
  """
  def gerar_movimentos(mapa, k) do
    {x, y, larg, alt, tipo} = mapa[k]
    mapa_sem_k = Map.drop(mapa, [k])

    cond do
      tipo == "v" -> mover_vertical(mapa_sem_k, k, x, y, larg, alt, tipo)
      tipo == "h" -> mover_horizontal(mapa_sem_k, k, x, y, larg, alt, tipo)
      tipo == "b" -> mover_bloco(mapa_sem_k, k, x, y, larg, alt, tipo)
      true -> :erro
    end
  end

  @doc """
  Movimentos permitidos para bloco vertical.
  """
  def mover_vertical(mapa, k, x, y, larg, alt, tipo) do
    mov1 = Map.put(mapa, k, {x + 1, y, larg, alt, tipo})
    mov2 = Map.put(mapa, k, {x - 1, y, larg, alt, tipo})
    mov3 = Map.put(mapa, k, {x, y + 10000, larg, alt, tipo})
    mov4 = Map.put(mapa, k, {x, y - 10000, larg, alt, tipo})

    validar_movimentos([mov1, mov2, mov3, mov4], k)
  end

  @doc """
  Movimentos permitidos para bloco horizontal.
  """
  def mover_horizontal(mapa, k, x, y, larg, alt, tipo) do
    mov1 = Map.put(mapa, k, {x + 10000, y, larg, alt, tipo})
    mov2 = Map.put(mapa, k, {x - 10000, y, larg, alt, tipo})
    mov3 = Map.put(mapa, k, {x, y + 1, larg, alt, tipo})
    mov4 = Map.put(mapa, k, {x, y - 1, larg, alt, tipo})

    validar_movimentos([mov1, mov2, mov3, mov4], k)
  end

  @doc """
  Movimentos permitidos para bloco livre (`b`).
  """
  def mover_bloco(mapa, k, x, y, larg, alt, tipo) do
    mov1 = Map.put(mapa, k, {x + 1, y, larg, alt, tipo})
    mov2 = Map.put(mapa, k, {x - 1, y, larg, alt, tipo})
    mov3 = Map.put(mapa, k, {x, y + 1, larg, alt, tipo})
    mov4 = Map.put(mapa, k, {x, y - 1, larg, alt, tipo})

    validar_movimentos([mov1, mov2, mov3, mov4], k)
  end

  @doc """
  Filtra uma lista de estados mantendo apenas os válidos.
  """
  def validar_movimentos(movimentos, k) do
    Enum.filter(movimentos, fn mapa ->
      tamanho_valido(mapa) == :ok and checar_sobreposicao(mapa, k) == :ok
    end)
  end

  @doc """
  Checa se o movimento causa sobreposição com outros blocos.
  """
  def checar_sobreposicao(mapa, k) do
    mapa_sem_k = Map.drop(mapa, [0])
    validar_sobreposicao(mapa_sem_k, k)
  end

  @doc """
  Verifica sobreposição entre um bloco e todos os outros.
  """
  def validar_sobreposicao(mapa, k) do
    {x, y, larg, alt, _} = mapa[k]
    mapa_restante = Map.drop(mapa, [k])

    Enum.reduce_while(mapa_restante, :ok, fn {_, {x2, y2, larg2, alt2, _}}, _ ->
      if x + larg <= x2 or x2 + larg2 <= x or y + alt <= y2 or y2 + alt2 <= y do
        {:cont, :ok}
      else
        {:halt, :erro}
      end
    end)
  end

  @doc """
  Verifica se o bloco 1 atingiu o lado direito do tabuleiro.
  """
  def objetivo_alcancado?(mapa) do
    {largura, _} = mapa[0]
    {_, {_, y1, lar, _, _}} = Enum.find(mapa, fn {k, _} -> k == 1 end)
    y1 + lar == largura + 1
  end

  @doc """
  Executa BFS retornando o caminho encontrado ou `:sem_caminho`.
  """
  def bfs(inicio, gerar, objetivo) do
    fila = :queue.from_list([{inicio, [inicio]}])
    visitados = MapSet.new([inicio])
    bfs_loop(fila, visitados, gerar, objetivo)
  end

  defp bfs_loop(fila, visitados, gerar, objetivo) do
    case :queue.out(fila) do
      {:empty, _} -> :sem_caminho

      {{:value, {atual, caminho}}, resto} ->
        if objetivo.(atual) do
          {:ok, Enum.reverse(caminho)}
        else
          {novos_visitados, novos_nos} =
            for viz <- gerar.(atual), reduce: {visitados, []} do
              {vis, acc} ->
                if MapSet.member?(vis, viz) do
                  {vis, acc}
                else
                  {MapSet.put(vis, viz), [{viz, [viz | caminho]} | acc]}
                end
            end

          bfs_loop(
            :queue.join(resto, :queue.from_list(Enum.reverse(novos_nos))),
            novos_visitados,
            gerar,
            objetivo
          )
        end
    end
  end

  @doc """
  Converte o caminho de estados em lista de strings de movimentos.
  """
  def gerar_lista_de_passos(:sem_caminho), do: []
  def gerar_lista_de_passos({:ok, caminho}), do: listas(caminho)

  def listas([]), do: []
  def listas([_]), do: []
  def listas([a, b | t]) do
    [colocandostring(achar_blocodiff(a, b)) | listas([b | t])]
  end

  @doc """
  Identifica qual bloco mudou de posição entre dois estados.
  """
  def achar_blocodiff(a, k) do
    mapaa = Map.drop(a, [0])
    mapak = Map.drop(k, [0])

    Enum.reduce_while(mapaa, :ok, fn {key, {x2, y2, _, _, _}}, _ ->
      case Map.fetch(mapak, key) do
        {:ok, {x_b, y_b, _, _, _}} ->
          if x2 == x_b and y2 == y_b do
            {:cont, :ok}
          else
            {:halt, {x2, y2, x_b, y_b, key}}
          end
      end
    end)
  end

  @doc """
  Dado o movimento entre dois estados, gera a frase correspondente:

    * `"Move block K NORTH, 1 step"`
    * `"Move block K EAST, 1 step"`
  """
  def colocandostring({x1, y1, x2, y2, k}) do
    cond do
      x1 > x2 -> "Move block #{k} NORTH, 1 step"
      x2 > x1 -> "Move block #{k} SOUTH, 1 step"
      y1 > y2 -> "Move block #{k} WEST, 1 step"
      y2 > y1 -> "Move block #{k} EAST, 1 step"
    end
  end

  @doc """
  Compacta movimentos repetidos consecutivos:

  ### Exemplo

      ["Move block 3 EAST, 1 step", "Move block 3 EAST, 1 step"]

  vira:

      "Move block 3 EAST, 2 steps"
  """
  def compactar_passos(lista) do
    lista
    |> Enum.chunk_by(& &1)
    |> Enum.map(fn grupo ->
      elem = hd(grupo)
      count = length(grupo)

      base = String.trim_trailing(elem, "1 step")

      passos =
        if count == 1 do
          "1 step"
        else
          "#{count} steps"
        end

      base <> passos
    end)
  end

  @doc """
  Exibe os resultados no terminal.
  """
  def kk([]) do
    IO.puts("Nao tem solucao")
  end

  def kk([a | t]) do
    imprimir_saida([a | t])
  end

  def imprimir_saida([]) do
    IO.puts("Deu certo!!!")
  end

  def imprimir_saida([a | t]) do
    IO.puts(a)
    imprimir_saida(t)
  end
end
