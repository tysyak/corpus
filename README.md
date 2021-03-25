
# Table of Contents

1.  [Introducción](#sec:introduccion)
    1.  [Frecuencia de término](#sec:frec-de-term)
    2.  [Frecuencia de documento inversa](#sec:frec-de-docum)
    3.  [Frecuencia de término: frecuencia de documento inversa](#sec:frec-de-term-1)
2.  [Desarrollo](#sec:desarrollo)
3.  [Compilación y ejecución](#sec:compilacion)


<a id="sec:introduccion"></a>

# Introducción

medida Tf-idf es una medida estadística que se utiliza en la
recuperación de información para evaluar la relevancia de los términos
en los documentos de una colección de documentos.

-   El tf-idf es el producto de dos estadísticas, frecuencia de término y
    frecuencia de documento inversa Hay varias formas de determinar los
    valores exactos de ambas estadísticas.

-   Una fórmula que tiene como objetivo definir la importancia de una
    palabra clave o frase dentro de un documento o una página web.


<a id="sec:frec-de-term"></a>

## Frecuencia de término

La frecuencia del término, \(tf(t, d)\), es la frecuencia del término \(t\).
\[tf(t,d)\frac{f_{t,d}}{\sum_{t^{i}\in d}f_{t^{i}, d}}\] donde
\(f_{t, d}\) es el recuento bruto de un término en un documento, es decir,
el número de veces que el término \(t\) aparece en el documento \(d\). Hay
varias otras formas de definir la frecuencia de los términos:

-   el recuento bruto en sí mismo: \(tf(t, d) = f(t, d)\).

-   &ldquo;Frecuencias&rdquo; booleanas: \(tf(t, d ) = 1\) si \(t\) ocurre en \(d\) y \(0\) en
    caso contrario.

-   frecuencia de término ajustada a la longitud del documento:
    \(tf(t, d) = \frac{f_{t, d}}{(numero\ de\ palabras\ en\ d)}\).

-   frecuencia escalada logarítmicamente:
    \(tf(t, d) = \log{(1 + f_{ t , d})}\).

-   frecuencia aumentada, para evitar un sesgo hacia documentos más
    largos, por ejemplo, frecuencia sin procesar dividida por la
    frecuencia sin procesar del término más frecuente en el documento.
    \[tf(t,d)=0.5+0.5 \times \frac{f_{t, d}}{max\{f_{t^{i}, d}: t^{i} \in d\}}\]


<a id="sec:frec-de-docum"></a>

## Frecuencia de documento inversa

La frecuencia inversa del documento es una medida de cuánta información
proporciona la palabra, es decir, si es común o rara en todos los
documentos. Es la fracción inversa escalada logarítmicamente de los
documentos que contienen la palabra (obtenida dividiendo el número total
de documentos por el número de documentos que contienen el término, y
luego tomando el logaritmo de ese cociente):

-   \(N\): Número total de documentos en el corpus \(N = |D|\).

-   \(|\{d \in D : t \in d\}|\): número de documentos donde aparece el
    término, es decir, si el término no está en el corpus, esto dará lugar
    a una división por cero. Por lo tanto, es común ajustar el denominador
    a \(tf(t,d) \ne 01 + |\{d \in D : t \in d \}|\)


<a id="sec:frec-de-term-1"></a>

## Frecuencia de término: frecuencia de documento inversa

Entonces tf &#x2013; idf se calcula como:
\[tf \times idf(t,d,D) = tf(t,d) \cdot idf(t,D)\]


<a id="sec:desarrollo"></a>

# Desarrollo

Para calcular la frecuencia de término
(sección [1.1](#sec:frec-de-term)) se elimino los espacios, comas y
palabras de poca utilidad para despues guradarlas en una lista; para el
manejo del lenguaje se convirtieron en átomos cada palabra.


```elixir
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
```

Posteriormente obtemos la concurrencia de cada palabra (no se usa) en el
texto, e inmediatamente se separa la palabras en listas de diez dentro
de una lista.

```elixir
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
```

Se calcula \(idf\) usando la formula del logaritmo planteada en las
sección [1.2](#sec:frec-de-docum):

```elixir
        idf_list = for {x, _y} <- vc do
          {x, :math.log10(length(ten_doc)/(vc[x])) }
        end
        |> List.keysort(0)
        |> Enum.reverse
```

Se calcula \(tf\) usando la formula del el recuento bruto en sí mismo
planteada en las sección [1.1](#sec:frec-de-term):
```elixir
        tf_list =  for {key_all, val_all} <- freq_words_all_text do
          {key_all, val_all/length(list_all_body)}
        end
        |> List.keysort(0)
        |> Enum.reverse
        # Obenemos la Tf de cada palabra
```

y para frecuencia de término: frecuencia de documento inversa:

```elixir
vals_tfxidf = for({x,y}<-Enum.zip(vals_tf,vals_idf), do: x*y)
```

Para obtener la gráficas se uso una biblioteca que usa ploty.js para
renderizarla en un documento html
(figura 1).
![Dercarga de svg generada por el doc html
generado](./doc/output.jpg)

También se genera un archivo CSV para comparar resultados.

 <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-right" />

<col  class="org-right" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Palabra</th>
<th scope="col" class="org-right">TF</th>
<th scope="col" class="org-right">IDF</th>
<th scope="col" class="org-right">TDxIDF</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">�nico</td>
<td class="org-right">0.000677</td>
<td class="org-right">2.170261</td>
<td class="org-right">0.00147</td>
</tr>


<tr>
<td class="org-left">�ndole</td>
<td class="org-right">0.000677</td>
<td class="org-right">2.170261</td>
<td class="org-right">0.00147</td>
</tr>


<tr>
<td class="org-left">�tnicos</td>
<td class="org-right">0.000677</td>
<td class="org-right">2.170261</td>
<td class="org-right">0.00147</td>
</tr>


<tr>
<td class="org-left">�l</td>
<td class="org-right">0.001355</td>
<td class="org-right">1.869231</td>
<td class="org-right">0.00253</td>
</tr>


<tr>
<td class="org-left">y</td>
<td class="org-right">0.000677</td>
<td class="org-right">2.170261</td>
<td class="org-right">0.00147</td>
</tr>


<tr>
<td class="org-left">voto</td>
<td class="org-right">0.001355</td>
<td class="org-right">1.869231</td>
<td class="org-right">0.00253</td>
</tr>


<tr>
<td class="org-left">voluntad</td>
<td class="org-right">0.002033</td>
<td class="org-right">1.693140</td>
<td class="org-right">0.00344</td>
</tr>


<tr>
<td class="org-left">vivienda</td>
<td class="org-right">0.000677</td>
<td class="org-right">2.170261</td>
<td class="org-right">0.00147</td>
</tr>


<tr>
<td class="org-left">viudez</td>
<td class="org-right">0.000677</td>
<td class="org-right">2.170261</td>
<td class="org-right">0.00147</td>
</tr>


<tr>
<td class="org-left">violen</td>
<td class="org-right">0.000677</td>
<td class="org-right">2.170261</td>
<td class="org-right">0.00147</td>
</tr>


<tr>
<td class="org-left">&#x2026;</td>
<td class="org-right">&#x2026;</td>
<td class="org-right">&#x2026;</td>
<td class="org-right">&#x2026;</td>
</tr>
</tbody>
</table>



<a id="sec:compilacion"></a>

# Compilación y ejecución

``` shell-session
# pacman -S elixir
```

Clonamos el repositorio <https://github.com/tysyak/corpus.git>,
obtenemos las dependencias y lo compilamos para generar el ejecutable
para despues ejecutarlo como argumento el texto.

``` shell-session
sh-5.1$ git clone https://github.com/tysyak/corpus.git
Clonando en 'corpus'...
remote: Enumerating objects: 30, done.
remote: Counting objects: 100% (30/30), done.
remote: Compressing objects: 100% (20/20), done.
remote: Total 30 (delta 6), reused 30 (delta 6), pack-reused 0
Recibiendo objetos: 100% (30/30), 1.09 MiB | 2.57 MiB/s, listo.
Resolviendo deltas: 100% (6/6), listo.
sh-5.1$ cd corpus/
sh-5.1$ mix deps.get
* Getting plotly_ex (https://github.com/tysyak/plotly_ex.git)
remote: Enumerating objects: 8, done.
remote: Counting objects: 100% (8/8), done.
remote: Compressing objects: 100% (7/7), done.
remote: Total 135 (delta 0), reused 6 (delta 0), pack-reused 127
Resolving Hex dependencies...
Dependency resolution completed:
Unchanged:
  jason 1.2.2
* Getting jason (Hex package)
sh-5.1$ mix escript.build
==> jason
Compiling 8 files (.ex)
Generated jason app
==> plotly_ex
Compiling 2 files (.ex)
Generated plotly_ex app
==> corpus
Compiling 1 file (.ex)
Generated corpus app
Generated escript corpus with MIX_ENV=dev
sh-5.1$ ./corpus textos/es.txt
listening on http://localhost:39715
accepted. quitting...
listening on http://localhost:44845
accepted. quitting...
listening on http://localhost:33977
accepted. quitting...
listening on http://localhost:46283
accepted. quitting...
```
