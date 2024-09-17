#include "custom_env.hpp"

void custom_env::load_dotenv() {
	std::ifstream env_file(".env");
	std::string line;
	while (std::getline(env_file, line)) {
		size_t delimiter_pos = line.find('=');
		if (delimiter_pos != std::string::npos) {
			std::string key = line.substr(0, delimiter_pos);
			std::string value = line.substr(delimiter_pos + 1);
			#ifdef _WIN32
				SetEnvironmentVariable(key.c_str(), value.c_str());
			#else
				setenv(key.c_str(), value.c_str(), 1);
			#endif
		}
	}
}

#ifdef _WIN32
	std::string custom_env::get_env_var(const std::string& name) {
		DWORD buffer_size = GetEnvironmentVariable(name.c_str(), nullptr, 0);
		if (buffer_size == 0) {
			return "";
		}

		std::string value;
		value.resize(buffer_size);
		if (GetEnvironmentVariable(name.c_str(), &value[0], buffer_size) == 0) {
			return "";
		}
		value.pop_back();
		return value;
	}
#else
	std::string custom_env::get_env_var(const std::string& name) {
		const char* value = std::getenv(name.c_str());
		if (value == nullptr) {
			return "";
		}
		return std::string(value);
	}
#endif

std::string custom_env::get_str_param(const char* param_name) {
	std::string value = custom_env::get_env_var(std::string(param_name));
	if (value.empty()) {
		return "error";
	}
	return value;
}

int64_t custom_env::get_int_param(const char* param_name){
	std::string value = custom_env::get_env_var(std::string(param_name));
	if (value.empty()) {
		return 0;
	}
	return std::stoll(value);
}
