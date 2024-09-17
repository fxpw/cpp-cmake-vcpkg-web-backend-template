#ifndef CUSTOM_ENV_HPP
#define CUSTOM_ENV_HPP

	#include <iostream>
	#include <fstream>
	#include <string>
	#include <fmt/format.h>

	#ifdef _WIN32
		#include <windows.h>
		#include <windef.h>
		#include <stdlib.h>
	#else
		#include <cstdlib>
	#endif

	namespace custom_env {
		void load_dotenv();
		std::string get_str_param(const char* param_name);
		int64_t get_int_param(const char* param_name);
		std::string get_env_var(const std::string& name);

	
}

#endif // CUSTOM_ENV_HPP
