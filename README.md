# The-Horse-Wall-Street
La estrategia del bot esta basada en el rompimiento de maximos y minimos , calcula el maximo y el minimo en la cantidad de velas puestas en el parametro , ademas trabaja con control horario para evitar esas horas lentas del mercado o en los momentos donde aumenta el spreed de manera exponencial ya que podria sacar operaciones en perdida.
El bot es optimizable en cualquier par de forex.
Entradas Generales:
Magic Number: Un número único que identifica las órdenes de este Asesor Experto (EA) para diferenciarlas de otras órdenes.
Balance Personalizado: Permite usar un balance fijo en lugar del balance real de la cuenta, útil cuando se desea simular o gestionar un capital específico para la estrategia.
Gestión de Lote: Existen tres modos para definir el tamaño del lote:
Fijo: Se usa siempre el mismo tamaño de lote.
Por Dinero: El tamaño del lote depende de una cantidad específica de dinero.
Por Porcentaje: El tamaño del lote es un porcentaje del balance de la cuenta.
Spread Máximo: Limita el spread máximo permitido para abrir operaciones. Si el spread es mayor que este valor, la operación no se abrirá.
Take Profit y Stop Loss: Define las distancias en puntos para el Take Profit y el Stop Loss, los cuales son los niveles donde se cierran las operaciones con ganancia o pérdida.
Marco de Tiempo: Establece el periodo de tiempo para la estrategia, como por ejemplo, H1 (1 hora), M15 (15 minutos), etc.
Remontar la Pérdida:
Aumento de Lote tras Pérdidas: Si se activa, el tamaño del lote aumenta tras una operación perdedora para intentar recuperar la pérdida en la siguiente operación.
Incremento de Lote: El valor específico con el que se incrementa el tamaño del lote tras una pérdida.
Trailing Stop:
Activar Trailing Stop: Permite que el Stop Loss se mueva a medida que el precio avanza a favor de la operación, asegurando ganancias a medida que el precio se mueve a favor.
Puntos para Activar y Seguir el Precio: Define los puntos que debe avanzar el precio para que el Trailing Stop se active y mueva el Stop Loss a un nivel más favorable.
Break Even por Niveles:
Activar Break Even: Permite mover el Stop Loss al punto de entrada (Break Even) una vez que la operación alcanza un nivel de ganancia determinado.
Distancia para Activar Break Even: Define cuántos puntos de ganancia deben alcanzarse antes de mover el Stop Loss a Break Even.
Puntos para Nivel de Ganancia: Define diferentes niveles de Take Profit, donde el Stop Loss se ajusta automáticamente a Break Even según los puntos de ganancia alcanzados.
Cierre de Operaciones:
Cerrar al Final de Tiempo: Permite cerrar todas las operaciones al final de un rango de tiempo específico, ideal para evitar mantener operaciones abiertas durante la noche o fuera de los horarios de trading preferidos.
Periodo de Tiempo:
Modo de Colocación de Órdenes: Define cómo se colocan las órdenes: normal o invertido (por ejemplo, vender cuando normalmente se compraría).
Número de Barras a Analizar: Establece cuántas barras o velas se deben analizar antes de tomar una decisión de trading.
Expiración de Órdenes: Define el número de barras después de las cuales una orden pendiente caducará si no se ejecuta.
Separación de Órdenes: Define la distancia mínima en puntos entre las órdenes pendientes para evitar que se acumulen demasiadas órdenes en el mismo nivel.
Filtro de Órdenes:
Ajuste de Órdenes: Permite activar o desactivar un ajuste de las órdenes basándose en el comportamiento del mercado, como aumentar o disminuir el máximo y mínimo de las operaciones para adaptarse a las condiciones del mercado.
Distancia de Ajuste: Establece cuántos puntos debe moverse una orden para que se realice el ajuste.
Filtro de Noticias:
Palabras Clave de Noticias: Utiliza palabras clave para identificar noticias económicas o políticas importantes que puedan afectar al mercado.
Monedas Relacionadas con las Noticias: Filtra las noticias según las monedas que afectan, como USD, EUR, JPY, etc.
Detener y Reanudar el Trading: Detiene el trading antes de una noticia importante y lo reanuda después, en un rango de tiempo definido.
Filtro RSI:
Filtro RSI: Permite usar el indicador RSI para filtrar las operaciones. Se pueden definir los niveles de sobrecompra y sobreventa para tomar decisiones basadas en la condición del mercado.
Período y Marco de Tiempo del RSI: Define el periodo del cálculo del RSI y el marco de tiempo en el que se va a aplicar.
Filtro Media Móvil:
Filtro Media Móvil: Permite usar una media móvil para filtrar las operaciones. Si el precio está por encima o por debajo de la media móvil, puede indicar una tendencia alcista o bajista.
Porcentaje de Distancia entre el Precio y la Media Móvil: Define el porcentaje que debe haber entre el precio actual y la media móvil para confirmar una señal de trading.
Método y Tipo de Media Móvil: Define qué tipo de media móvil usar (simple, exponencial, etc.) y el tipo de precio (cierre, apertura, etc.) para su cálculo.
