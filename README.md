# Introducción {#sec:introduccion}

medida Tf-idf es una medida estadística que se utiliza en la
recuperación de información para evaluar la relevancia de los términos
en los documentos de una colección de documentos.

-   El tf-idf es el producto de dos estadísticas, frecuencia de término
    y frecuencia de documento inversa Hay varias formas de determinar
    los valores exactos de ambas estadísticas.

-   Una fórmula que tiene como objetivo definir la importancia de una
    palabra clave o frase dentro de un documento o una página web.

## Frecuencia de término {#sec:frec-de-term}

La frecuencia del término, $tf(t, d)$, es la frecuencia del término $t$.
$$tf(t,d)\frac{f_{t,d}}{\sum_{t^{i}\in d}f_{t^{i}, d}}$$ donde
$f_{t, d}$ es el recuento bruto de un término en un documento, es decir,
el número de veces que el término $t$ aparece en el documento $d$. Hay
varias otras formas de definir la frecuencia de los términos:

-   el recuento bruto en sí mismo: $tf(t, d) = f(t, d)$.

-   "Frecuencias" booleanas: $tf(t, d ) = 1$ si $t$ ocurre en $d$ y $0$
    en caso contrario.

-   frecuencia de término ajustada a la longitud del documento:
    $tf(t, d) = \frac{f_{t, d}}{(numero\ de\ palabras\ en\ d)}$.

-   frecuencia escalada logarítmicamente:
    $tf(t, d) = \log{(1 + f_{ t , d})}$.

-   frecuencia aumentada, para evitar un sesgo hacia documentos más
    largos, por ejemplo, frecuencia sin procesar dividida por la
    frecuencia sin procesar del término más frecuente en el documento.
    $$tf(t,d)=0.5+0.5 \times \frac{f_{t, d}}{max\{f_{t^{i}, d}: t^{i} \in d\}}$$

## Frecuencia de documento inversa {#sec:frec-de-docum}

La frecuencia inversa del documento es una medida de cuánta información
proporciona la palabra, es decir, si es común o rara en todos los
documentos. Es la fracción inversa escalada logarítmicamente de los
documentos que contienen la palabra (obtenida dividiendo el número total
de documentos por el número de documentos que contienen el término, y
luego tomando el logaritmo de ese cociente):

-   $N$: Número total de documentos en el corpus $N = |D|$.

-   $|\{d \in D : t \in d\}|$: número de documentos donde aparece el
    término, es decir, si el término no está en el corpus, esto dará
    lugar a una división por cero. Por lo tanto, es común ajustar el
    denominador a $tf(t,d) \ne 01 + |\{d \in D : t \in d \}|$

## Frecuencia de término: frecuencia de documento inversa {#sec:frec-de-term-1}

Entonces tf -- idf se calcula como:
$$tf \times idf(t,d,D) = tf(t,d) \cdot idf(t,D)$$

# Desarrollo {#sec:desarrollo}

Para calcular la frecuencia de término
(sección [1.1](#sec:frec-de-term){reference-type="ref"
reference="sec:frec-de-term"}) se elimino los espacios, comas y palabras
de poca utilidad para despues guradarlas en una lista; para el manejo
del lenguaje se convirtieron en átomos cada palabra.

``` {.elixir firstline="5" lastline="26"}
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
```

Posteriormente obtemos la concurrencia de cada palabra (no se usa) en el
texto, e inmediatamente se separa la palabras en listas de diez dentro
de una lista.

``` {.elixir firstline="29" lastline="43"}
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
```

Se calcula $idf$ usando la formula del logaritmo planteada en las
sección [1.2](#sec:frec-de-docum){reference-type="ref"
reference="sec:frec-de-docum"}:

``` {.elixir firstline="45" lastline="49"}
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
```

Se calcula $tf$ usando la formula del el recuento bruto en sí mismo
planteada en las sección [1.1](#sec:frec-de-term){reference-type="ref"
reference="sec:frec-de-term"}:

``` {.elixir firstline="51" lastline="56"}
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
```

y para frecuencia de término: frecuencia de documento inversa:

``` {.elixir firstline="65" lastline="67"}
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
```

Para obtener la gráficas se uso una biblioteca que usa ploty.js para
renderizarla en un documento html
(figura [1](#fig:1){reference-type="ref" reference="fig:1"}).\
\
\
\
\
\

![Dercarga de svg generada por el doc html
generado](./doc/output.jpg){#fig:1 width="\\linewidth"}

También se genera un archivo CSV para comparar resultados.

  Palabra    TF         IDF        TDxIDF
  ---------- ---------- ---------- ---------
  �nico      0.000677   2.170261   0.00147
  �ndole     0.000677   2.170261   0.00147
  �tnicos    0.000677   2.170261   0.00147
  �l         0.001355   1.869231   0.00253
  y          0.000677   2.170261   0.00147
  voto       0.001355   1.869231   0.00253
  voluntad   0.002033   1.693140   0.00344
  vivienda   0.000677   2.170261   0.00147
  viudez     0.000677   2.170261   0.00147
  violen     0.000677   2.170261   0.00147
  ...        ...        ...        ...

# Compilación y ejecución {#sec:compilacion}

Usando un sistema arch linux, mediante el uso del gestor de paquetes
ejecutar los siguientes comandos(como administrador) para instalar
elixir, donde tambien instalará la máquina virtual de erlang.

``` {.shell-session}
# pacman -S elixir
```
