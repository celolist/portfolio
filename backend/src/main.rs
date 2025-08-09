use actix_web::{get, App, HttpServer, Responder, HttpResponse};
use serde::Serialize;

#[derive(Serialize)]
struct Greeting {
    message: String,
}

#[get("/api/hello")]
async fn hello() -> impl Responder {
    let greeting = Greeting {
        message: "Hello from Rust API!".to_string(),
    };
    HttpResponse::Ok().json(greeting)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| App::new().service(hello))
        .bind(("0.0.0.0", 8080))?
        .run()
        .await
}