const amqp = require("amqplib");
const config = require("../config");
const OrderService = require("../services/orderService");

class MessageBroker {
  static async connect() {
    const connectWithRetry = async () => {
      try {
        console.log("Attempting to connect to RabbitMQ...");
        const connection = await amqp.connect(config.rabbitMQURI);
        const channel = await connection.createChannel();

        // Declare the order queue
        await channel.assertQueue(config.rabbitMQQueue, { durable: true });
        console.log("RabbitMQ connected successfully for orders");

        // Consume messages from the order queue on buy
        channel.consume(config.rabbitMQQueue, async (message) => {
          try {
            const order = JSON.parse(message.content.toString());
            const orderService = new OrderService();
            await orderService.createOrder(order);
            channel.ack(message);
          } catch (error) {
            console.error(error);
            channel.reject(message, false);
          }
        });
      } catch (error) {
        console.error("Failed to connect to RabbitMQ:", error.message);
        console.log("Retrying in 5 seconds...");
        setTimeout(connectWithRetry, 5000);
      }
    };

    // Wait 30 seconds then start trying to connect
    setTimeout(connectWithRetry, 30000);
  }
}

module.exports = MessageBroker;
