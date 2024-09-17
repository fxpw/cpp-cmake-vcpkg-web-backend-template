#include <iostream>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>
#include <cstdlib>
#include <fmt/format.h>
#include <custom_env.hpp>

typedef std::function<void(const drogon::HttpResponsePtr &)> Callback;

void apiHandler(const drogon::HttpRequestPtr &request, Callback &&callback)
{
	LOG_INFO << "Received request for /api";
	std::string _APP_NAME = custom_env::get_str_param("APP_NAME");
	Json::Value jsonBody;
	jsonBody["message"] = "Hello from " + _APP_NAME;
	jsonBody["status"] = "success";

	auto response = drogon::HttpResponse::newHttpJsonResponse(jsonBody);
	response->addHeader("Access-Control-Allow-Origin", "*");
	response->addHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
	response->addHeader("Access-Control-Allow-Headers", "Content-Type");
	callback(response);
}

int main()
{
	custom_env::load_dotenv();
	std::string _BACKEND_PORT = custom_env::get_str_param("BACKEND_PORT");
	std::string db_username = custom_env::get_str_param("DB_USERNAME");
	std::string db_password = custom_env::get_str_param("DB_PASSWORD");
	std::string db_host = "127.0.0.1"; // Assuming localhost, change if necessary
	std::string db_port = custom_env::get_str_param("DB_PORT");
	std::string db_database = custom_env::get_str_param("DB_DATABASE");
	std::string connectionString = fmt::format("host={} port={} dbname={} user={} password={}",
											   db_host, db_port, db_database, db_username, db_password);
	LOG_INFO << "Database connection string: " << connectionString;
	auto dbClient = drogon::orm::DbClient::newMysqlClient(
		connectionString,
		1);
	if (!dbClient) {
        LOG_ERROR << "Failed to create the database client."; // Error handling
        return 1; // Exit on error
    }
	LOG_INFO << "Server is running on port " << _BACKEND_PORT;
	drogon::app()
		.loadConfigFile("./server_config.json")
		.registerHandler("/api", &apiHandler, {drogon::Get})
		.run();

	return 0;
}