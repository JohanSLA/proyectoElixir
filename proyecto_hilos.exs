defmodule DistributedSATSolver do
  # Función principal que se ejecuta al llamar al módulo
  def main() do
    "uf20-01.cnf"          # Nombre del archivo CNF que contiene el problema SAT
    |> leer_cnf()          # Leer y procesar el archivo
    |> solve()             # Resolver el problema usando DPLL
  end

  # Lee el archivo CNF y extraer las cláusulas válidas
  defp leer_cnf(nombre_archivo) do
    File.read!(nombre_archivo)        # Leer el archivo completo como texto
    |> String.split("\n")            # Divide el texto en líneas
    |> Enum.filter(&filtrar_lineas_validas/1) # Filtra las líneas válidas (descartar comentarios y metadata)
    |> Enum.map(&extraer_clausula/1) # Convertir las líneas válidas en listas de literales
  end

  # Filtrar líneas que no son parte de las cláusulas
  defp filtrar_lineas_validas(linea) do
    not (String.starts_with?(linea, "c") or  # Comentarios
         String.starts_with?(linea, "p") or  # Información del problema
         linea in ["%", "", "0"])           # Delimitadores
  end

  # Extraer una cláusula válida convirtiendo cada línea en una lista de enteros
  defp extraer_clausula(linea) do
    linea
    |> String.split()           # Dividir la línea en palabras
    |> Enum.map(&String.to_integer/1) # Convertir cada palabra en entero
    |> Enum.reject(&(&1 == 0))  # Eliminar los ceros (delimitadores)
  end

  # Resuelve el problema SAT usando la técnica de búsqueda paralela
  def solve(clausulas) do
    solutions = parallel_dpll(clausulas, []) # Llama al algoritmo DPLL con un conjunto vacío de asignaciones

    if solutions == [] do
      IO.puts("Insatisfactible")  # No hay solución
    else
      IO.puts("Satisfactible")   # Existe al menos una solución

      # Muestra cada solución como una cadena de bits
      solutions
      |> Enum.each(fn sol ->
        binary_solution = format_as_binary(sol)
        IO.puts("#{inspect(binary_solution)}")
      end)
    end
  end

  # Implementación paralela del algoritmo DPLL
  defp parallel_dpll(clauses, assignment) do
    cond do
      # Caso base: Todas las cláusulas están satisfechas
      Enum.all?(clauses, &clause_satisfied?(&1, assignment)) ->
        [assignment] # Devolver la asignación como solución

      # Caso base: Hay una cláusula vacía (conflicto)
      Enum.any?(clauses, &(&1 == [])) ->
        [] # No hay solución en esta rama

      # Caso recursivo: Seleccionar un literal y dividir el trabajo
      true ->
        variable = select_variable(clauses, assignment) # Seleccionar una variable no asignada

        # Crear dos tareas paralelas para explorar ambas ramas
        task_true = Task.async(fn -> dpll(simplify(clauses, variable), [variable | assignment]) end)
        task_false = Task.async(fn -> dpll(simplify(clauses, -variable), [-variable | assignment]) end)

        # Esperar y combinar los resultados de ambas tareas
        Task.await(task_true, :infinity) ++ Task.await(task_false, :infinity)
    end
  end

  # Algoritmo DPLL estándar (sin paralelismo) usado por las tareas
  defp dpll(clauses, assignment) do
    cond do
      # Caso base: Todas las cláusulas están satisfechas
      Enum.all?(clauses, &clause_satisfied?(&1, assignment)) ->
        [assignment] # Devolver la asignación como solución

      # Caso base: Hay una cláusula vacía (conflicto)
      Enum.any?(clauses, &(&1 == [])) ->
        [] # No hay solución en esta rama

      # Caso recursivo: Seleccionar un literal y continuar la búsqueda
      true ->
        variable = select_variable(clauses, assignment) # Seleccionar una variable no asignada
        dpll(simplify(clauses, variable), [variable | assignment]) ++
          dpll(simplify(clauses, -variable), [-variable | assignment])
    end
  end

  # Simplificar las cláusulas eliminando literales satisfechos y reduciendo literales conflictivos
  defp simplify(clauses, variable) do
    Enum.reduce(clauses, [], fn clause, acc ->
      cond do
        variable in clause -> acc # La cláusula está satisfecha, no se incluye
        -variable in clause -> [List.delete(clause, -variable) | acc] # Eliminar el literal conflictivo
        true -> [clause | acc] # La cláusula permanece igual
      end
    end)
  end

  # Verificar si una cláusula está satisfecha con la asignación actual
  defp clause_satisfied?(clause, assignment) do
    Enum.any?(clause, &(&1 in assignment)) # Al menos un literal debe estar asignado como verdadero
  end

  # Seleccionar la próxima variable no asignada para explorar
  defp select_variable(clauses, assignment) do
    clauses
    |> Enum.flat_map(& &1) # Unir todas las cláusulas en una lista de literales
    |> Enum.uniq()         # Eliminar duplicados
    |> Enum.find(&(&1 not in assignment and -&1 not in assignment)) # Buscar una variable no asignada
  end

  # Formatear una solución como una cadena de bits
  defp format_as_binary(solution) do
    for i <- 1..20 do
      if i in solution, do: 1, else: 0 # 1 si la variable está en la solución, 0 si no
    end
  end
end

DistributedSATSolver.main()
