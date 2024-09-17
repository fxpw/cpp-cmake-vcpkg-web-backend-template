#include <iostream>
#include <drogon/drogon.h>
#include <cstdlib>
#include <fmt/format.h>
#include <custom_env.hpp>

typedef std::function<void(const drogon::HttpResponsePtr &)> Callback;

void apiHandler(const drogon::HttpRequestPtr &request, Callback &&callback)
{
	LOG_INFO << "Received request for /api";
	std::string _APP_NAME = custom_env::get_str_param("APP_NAME");
	Json::Value jsonBody;
	jsonBody["message"] = "Hello from "+_APP_NAME;
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
	LOG_INFO << "Server is running on port " << _BACKEND_PORT;
	drogon::app()
		.loadConfigFile("./server_config.json")
		.registerHandler("/api", &apiHandler, {drogon::Get})
		.run();

	return 0;
}