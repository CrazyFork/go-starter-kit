

* dep missing then execute:

  ```shell
  BIN           = $(GOPATH)/bin
  ON            = $(BIN)/on
  $(ON):
	go install $(IMPORT_PATH)/vendor/github.com/olebedev/on
  
  serve: $(ON) $(GO_BINDATA) clean $(BUNDLE) restart
  ```

* linux中shell变量$#,$@,$0,$1,$2的含义解释

    linux中shell变量$#,$@,$0,$1,$2的含义解释: 
    变量说明: 
    $$ 
    Shell本身的PID（ProcessID） 
    $! 
    Shell最后运行的后台Process的PID 
    $? 
    最后运行的命令的结束代码（返回值） 
    $- 
    使用Set命令设定的Flag一览 
    $* 
    所有参数列表。如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。 
    $@ 
    所有参数列表。如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。 
    $# 
    添加到Shell的参数个数 
    $0 
    Shell本身的文件名 
    $1～$n 
    添加到Shell的各参数值。$1是第1参数、$2是第2参数…。 


* $@ symbol:

    The $@ and $< are called the automatic variables. The $@ is the output variable. $< is called the first input variable. For example:

    hello.o: hello.c hello.h
            gcc -c $< -o $@
            
    Here, hello.o is the output file. This is what $@ exapnds to. The first dependency is hello.c. That's what $< expands to.

    The -c flag generates the .o file; see man gcc for a more detailed explanation. The -o specifies the file to output to.

    For further details, you can read this.

    