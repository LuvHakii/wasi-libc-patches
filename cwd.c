char *getenv(const char *);
int chdir(const char *);

__attribute__((constructor(65000))) static void cwd_from_pwd(void) {
	const char *pwd = getenv("PWD");
	if (pwd && pwd[0] == '/') chdir(pwd);
}
