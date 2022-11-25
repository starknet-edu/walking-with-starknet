# Haciendo debugging a un contrato de Cairo con Protostar

![portada](https://miro.medium.com/max/1400/1*fUl7yt9SYXqAOhpW6vMmyA.png)

¿Querés hacer imprimir una variable para ver su valor? ¿Tenés un contrato gigante que no compila y no podés encontrar el error? En este tutorial explico cómo hacer el debugging a un contrato Cairo.

Usaremos una funcionalidad de Cairo llamada hints, que permite inyectar código python arbitrariamente en tu código. El uso de hints es muy restringido en StarkNet y no se aplica en los contratos inteligentes. Pero es extremadamente útil para depurar su contrato.


## 1. Cómo Hacer Debugging
Agregaremos hints en donde queramos hacer el debugging. En estos hints armaremos un json con los datos que nos interesa imprimir y los enviaremos en una petición a un server que tendremos corriendo de forma local, en el cual se va a imprimir el json que armamos en el contrato.


## 2. Configuración
Debemos instalar Protostar y también flasky requests para el server.

Instalar protostar

`curl -L https://raw.githubusercontent.com/software-mansion/protostar/master/install.sh | bash`

Instalar flask y requests

`pip install flask requests`

Consulta la [documentación](https://docs.swmansion.com/protostar/) de Protostar para obtener más detalles.


## 3. Estructura del proyecto

![portada](https://miro.medium.com/max/640/1*r7xzQLNb0DjE83i-5AVzjA.png)

Tenemos un contrato y sus respectivos tests. Además tenemos el server.

Repositorio del [proyecto](https://github.com/dpinones/starknet-debug-protostar).


## 4. Contrato main
El contrato main tiene una `@storage_var` llamada balance. También tiene la función llamada `get_balance` que retorna el balance actual y también tiene la función llamada `increase_balance` para aumentar el balance. El balance inicia en 0.

A la función llamada `increase_balance` le vamos a hacer debugging.

![portada](https://miro.medium.com/max/1400/1*swGdfWoI8kMS2fey_OtxEQ.png)

## 5. Test
Test de la función `increase_balance`.

![portada](https://miro.medium.com/max/1400/1*lEXdfjJC4qATkf8pe4DsIA.png)

## 6. Agregando hint
A la función `increase_balance` le agregamos un hint. En este armamos un json con los datos que quiero enviar al server. Para este caso quiero ver el balance actual y el nuevo balance.

Si observamos la forma de poder acceder desde el hint a las variables de Cairo es agregando adelante `ids.nombre-de-la-variable`. Ejemplo: `ids.new_balance` corresponde a la variable tempvar definida en la línea 18.

![portada](https://miro.medium.com/max/1400/1*yVcYBJ0BWtKeoFVRneHyrw.png)

## 6. Server
Levantamos el server en otra terminal y la dejamos corriendo.

`python3 bigBrainDebug/server.py`

![portada](https://miro.medium.com/max/1400/1*KwDAlzqACgp8zoAOLXk9-w.png)

## 7. Ejecutando test
Al ejecutar el comando test de protostar hay que especificar que deseamos usar hints no incluidos en la lista blanca de hints. Para esto a la hora de ejecutar el test debemos agregar la siguiente bandera: `--disable-hint-validation`.

En este caso queremos ejecutar el test llamado `test_increase_balance`.

`protostar test ./tests/test_main.cairo::test_increase_balance       --disable-hint-validation`

![portada](https://miro.medium.com/max/1400/1*VXZGnJYOyHLYugXDYtMNww.png)

Se ejecutó el test correctamente, por lo tanto debemos revisar la terminal donde está corriendo el server para ver que se estén imprimiendo los datos que estamos enviando.

## 7. Resultado
Como vemos en la terminal se visualiza el balance actual y el nuevo balance que es lo que queríamos. En el test llamado `test_increase_balance`, incrementa el balance en dos oportunidades. Primero llama a la función con el valor 42 (entonces el balance es 42) y luego llama a la función con el valor 58 (el balance es 100). Coincide con los valores mostrados en la terminal.

![portada](https://miro.medium.com/max/1400/1*5tFastkA4eQpFBKn-WjKkg.png)

**Una vez que terminamos de hacer el proceso de Debugging eliminamos los hints.**

## 8. Conclusión
Este tutorial está basado 100% en el repositorio [starknet-debug](https://github.com/starknet-edu/starknet-debug) de [starknet-edu](https://github.com/starknet-edu). En ese repositorio hay ejemplos usando el debugging en funciones recursivas y con structs.

La gran mayoría de veces no es necesario hacer el debugging de esta manera. Haciendo un test para una función particular y los assert correctos ya alcanzaría. Pero en una experiencia reciente teníamos que hacer el seguimiento de un algoritmo complejo para ver si estaba haciendo lo correcto o no. Con los test nos alcanzó hasta cierto momento, pero al tener muchas funciones, muchas líneas de código y muchos llamados recursivos se perdía el hilo de lo que estaba haciendo. El debugging de este tutorial nos fue útil y pudimos hacer el seguimiento del algoritmo correctamente.

Hints: https://www.cairo-lang.org/docs/how_cairo_works/hints.html

Repositorio: https://github.com/dpinones/starknet-debug-protostar

Twitter: https://twitter.com/dpinoness

GitHub: https://github.com/dpinones

