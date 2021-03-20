defmodule Corpus do
  @moduledoc """
  Documentation for `Corpus`.
  """

  @doc false
  def main(args \\ "./textos/es.txt") do
    case File.read(args) do
      {:ok, body} ->
        list_all_body = body
        |> String.downcase
        |> delete_simbols
        |> String.split
        |> lstring_to_latom
        # Obtenemos la lista en de todas las palabras en átomos


        freq_words_all_text = list_all_body
        |> Enum.frequencies
        |> Map.to_list
        |> List.keysort(1)
        |> Enum.reverse
        # Obtenemos las concurrencia de las palabras del texto

        [list_ten | _rest] = Enum.chunk_every(list_all_body, 10)
        # aqui cortamos a 10

        freq_list_ten = list_ten
        |> Enum.frequencies
        |> Map.to_list
        |> List.keysort(1)
        |> Enum.reverse
        # Ordenamos la relación palabra vs concurrencia

        # tf_list =  for {key_all, val_all} <- freq_words_all_text, {key, val} <- freq_list_ten  do
        #   # IO.puts "#{Atom.to_string(key)}: #{val_all/length(list_all_body)}"
        #   {key, val/length(list_all_body)}
        # end |> Enum.uniq |> IO.inspect

        tf_list =  for {key_all, val_all} <- freq_words_all_text do
          # IO.puts "#{Atom.to_string(key)}: #{val_all/length(list_all_body)}"
          {key_all, val_all/length(list_all_body)}
        end # |> IO.inspect
        # Obenemos la Tf de cada palabra

        ## Aqui, usando una libreria del autor, dibujamos un gráfico
        ##
        ## https://plotly.com
        trace = %{
          x: for({x,_y}<-tf_list, do: x),
          y: for({_x,y}<-tf_list, do: y),
          type: "scatter",
          mode: 'lines+markers',
          connectgaps: true,
          name: "TF"
        }


        [trace]
        |> PlotlyEx.plot(
          %{
            xaxis: %{
              title: %{text: "$\\text{TF}\\;$"},
            },
          })
          |> PlotlyEx.show
        # Terminamos de dibujar el gráfico

        System.halt(0) # salida 0 a terminal

      {:error, _error} ->
        IO.puts "Error, verifique el archivo"
        System.halt(1) #
        # Salida a 1 en la terminal
    end
  end

  @doc"""
  Eliminamos los símbolos y palabras que no querramos, por ejemplo «de, la, los,...»
  """
  def delete_simbols(string) do
    string #Regex.replace(~r/[,|;|\.|\(|\)|\d]+/, string, "")
    |> String.replace(
      ~r/,|;|\.|\(|\)|\d+|\sl(a|o)s?\s|\s+l(a|o)s\s|\sde(\sl(a|o)s?)?\s|\s(a|e|o)\s|\sy\s|\sel\s/u,
    " "
    )
  end

  defp lstring_to_latom(list_string) do
    for x <- list_string do
      String.to_atom(x)
    end
  end


end
