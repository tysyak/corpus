defmodule Corpus do
  @moduledoc """
  Documentation for `Corpus`.
  """
  @doc"""
  Devuelve la cantidad que el atomo aparece en la lista de documentos(una vez)
  """
  def atomo_en_lista(atomo, documentos) do
    {
      atomo,
      for(x <- documentos, do: atomo in x)
      |> Enum.reject(fn x -> x==false end)
      |> length
    }
  end

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

        ten_doc = Enum.chunk_every(list_all_body, 10)
        # aqui cortamos a 10

        vc = for(x <- list_all_body, do: atomo_en_lista(x, ten_doc))
        |> List.keysort(1)
        |> Enum.reverse
        |> Enum.uniq
        # Veces que aparece cada palabra en los 10 documentos

        idf_list = for {x, _y} <- vc do
          {x, :math.log10(length(ten_doc)/(vc[x])) }
        end
        |> List.keysort(0)
        |> Enum.reverse

        tf_list =  for {key_all, val_all} <- freq_words_all_text do
          {key_all, val_all/length(list_all_body)}
        end
        |> List.keysort(0)
        |> Enum.reverse
        # Obenemos la Tf de cada palabra



        ## Aqui, usando una libreria del autor, dibujamos un gráfico
        ##
        ## https://plotly.com
        equis = for({x,_y}<-tf_list, do: x)
        vals_idf = for {_x,y}<-idf_list, do: y
        vals_tf = for {_x,y}<-tf_list, do: y
        vals_tfxidf = for({x,y}<-Enum.zip(vals_tf,vals_idf), do: x*y)


        tf = %{
          x: equis,
          y: vals_tf,
          type: "scatter",
          mode: 'lines+markers',
          connectgaps: true,
          name: "TF"
        }

        idf = %{
          x: equis,
          y: vals_idf,
          type: "scatter",
          name: "IDF"
        }

        # Producto de TF y IDF
        tf_x_idf = %{
          x: equis,
          y: vals_tfxidf,
          type: "scatter",
          name: "tf*idf"
        }

        # dibujamos gráficos
        [idf]
        |> PlotlyEx.plot(
          %{
            xaxis: %{
              title: %{text: "$\\text{IDF}\\;$"},
            },
          })
          |> PlotlyEx.show

        [tf]
        |> PlotlyEx.plot(
          %{
            xaxis: %{
              title: %{text: "$\\text{TF}\\;$"},
            },
          })
          |> PlotlyEx.show

        [tf_x_idf]
        |> PlotlyEx.plot(
          %{
            xaxis: %{
              title: %{text: "$\\text{TFXIDF}\\;$"},
            },
          })
          |> PlotlyEx.show

        [tf,idf,tf_x_idf]
        |> PlotlyEx.plot(
          %{
            xaxis: %{
              title: %{text: "$\\text{TF,IDF,TFxIDF}\\;$"},
            },
          })
          |> PlotlyEx.show
        # Terminamos de dibujar los gráficos

        # escribimos el archivo por csv
        file = File.open!('out.csv', [:write])
        IO.write(file, "Palabra,TF,IDF,TDxIDF\n")
        to_csv(equis, vals_tf, vals_idf, vals_tfxidf, length(equis), file)
        File.close(file)
        # terminamos de escribor el archivo


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

  @doc"""
  Esta Funcion solo conbierte una lista con cadenas a atomos
  """
  def lstring_to_latom(list_string) do
    for x <- list_string do
      String.to_atom(x)
    end
  end

  @doc"""
  Esta funcion se encarga de llenar el archivo csv

  | palabra | TF | IDF | TFxIDF |
  """
  def to_csv(_atoms, _td, _ids, _tdxids, count, _file) when count <= 1 do
    :ok
  end
  def to_csv(atoms, td, ids, tdxids, count, file) do
    [h_atom| t_atom] = atoms
    [h_td| t_td] = td
    [h_ids| t_ids] = ids
    [h_tdxids| t_tdxids] = tdxids

    IO.write(file, "#{Atom.to_string(h_atom)},#{h_td},#{h_ids},#{h_tdxids}\n")

    to_csv(t_atom, t_td, t_ids, t_tdxids, count - 1, file)
  end

end
