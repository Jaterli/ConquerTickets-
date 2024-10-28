# ConquerTickets Smart Contract

## Descripción

`ConquerTickets` es un contrato inteligente en Solidity diseñado para la creación y gestión de tickets para eventos mediante tokens ERC1155. Los usuarios pueden comprar, transferir y validar tickets, mientras que el propietario del contrato puede crear nuevos eventos, cancelar eventos activos y retirar fondos generados por la venta de tickets.

## Funcionalidades Principales

### 1. Creación de Eventos
El contrato permite al propietario crear eventos, especificando:
- **Nombre del evento**
- **Cantidad total de tickets disponibles**
- **Precio de cada ticket**

Cada evento tiene un estado inicial de "activo" y un identificador único que lo distingue dentro del contrato.

### 2. Compra de Tickets
Los usuarios pueden comprar tickets para eventos activos pagando la cantidad correspondiente en ETH:
- El usuario envía ETH suficiente para comprar uno o varios tickets de un evento.
- Si el evento está cancelado o los tickets están agotados, la transacción se revierte.
- Si el usuario envía más ETH del necesario, recibe un reembolso del monto sobrante.

### 3. Transferencia de Tickets
- **Transferencia simple:** Los usuarios pueden transferir tickets a otra dirección.
- **Transferencia en lote:** Los usuarios también pueden transferir múltiples tipos de tickets a otra dirección en una sola transacción.
  
Ambos tipos de transferencias verifican que la cantidad de tickets transferida sea válida y que la dirección de destino no sea la dirección cero.

### 4. Validación de Tickets
Los usuarios pueden consultar la cantidad de tickets de un tipo específico en una dirección mediante la función `validateTicket`. Esto permite a otros servicios o contratos verificar la posesión de tickets para eventos específicos.

### 5. Reembolso de Tickets
Los usuarios pueden solicitar el reembolso de sus tickets para eventos activos:
- La función de reembolso devuelve el costo de compra de los tickets en ETH.
- La cantidad reembolsada se calcula en función del precio original del ticket y la cantidad solicitada para el reembolso.
- Los tickets reembolsados se queman, y el número de tickets disponibles aumenta.

### 6. Cancelación de Eventos
El propietario del contrato puede cancelar cualquier evento activo, evitando así futuras compras o reembolsos de tickets de dicho evento.

### 7. Retiro de Fondos
El propietario del contrato puede retirar los fondos generados por la venta de tickets, accediendo al balance acumulado en el contrato.

## Validaciones de Seguridad

Para garantizar una operación segura y lógica del contrato, se han añadido las siguientes validaciones:

1. **Restricciones de Entradas:** Los eventos deben tener nombre, precio y cantidad de tickets mayores a cero.
2. **Estado de los Eventos:** Las compras y reembolsos solo son posibles en eventos activos.
3. **Prevención de Transferencias Inválidas:** No se permite transferir a direcciones cero ni transferir cantidades mayores a las poseídas.
4. **Control de Eventos Cancelados:** Los eventos ya cancelados no pueden volver a ser cancelados, y los tickets de dichos eventos no pueden comprarse o reembolsarse.
5. **Balance de Contrato:** Se asegura que el contrato tenga saldo suficiente antes de permitir retiros.

## Eventos Emitidos

- `EventCreated`: Emitido cuando un evento es creado.
- `TicketBought`: Emitido cuando un usuario compra tickets.
- `EventCanceled`: Emitido cuando un evento es cancelado.

## Uso

1. **Despliegue del contrato:** El propietario despliega el contrato y queda autorizado para crear y gestionar eventos.
2. **Creación de un evento:** El propietario llama a `createEvent()` especificando los detalles del evento.
3. **Compra de tickets:** Los usuarios llaman a `buyTickets()` enviando el valor en ETH.
4. **Transferencia de tickets:** Los usuarios pueden transferir tickets usando `transferTickets()` o `transferTicketsBatch()`.
5. **Validación y reembolso:** Los usuarios validan sus tickets con `validateTicket()` o solicitan reembolso usando `refundTickets()` para eventos activos.
6. **Retiro de fondos:** El propietario retira los fondos del contrato acumulados por las ventas de tickets.

## Requisitos Previos

El contrato utiliza la biblioteca OpenZeppelin, en particular:
- `ERC1155`: Implementación del estándar para tokens fungibles y no fungibles.
- `Ownable`: Proporciona un sistema de permisos de propietario para funciones específicas.

## Consideraciones de Uso

Este contrato es una herramienta de emisión y gestión de tickets descentralizada, diseñada para entornos en los que se requiere trazabilidad, transparencia y seguridad en la gestión de eventos. Sin embargo, debido a la inmutabilidad de la blockchain, los eventos y transacciones registradas en el contrato no pueden ser modificados una vez ejecutados, lo que proporciona un alto nivel de confianza en el sistema de tickets.
