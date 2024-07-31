struct anontest {
  int foo;
  union {
    long int f1;
    long int __f1;
  };
  struct {
    long int f2;
    long int __f2;
  };
};

