//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//
// ガウス過程回帰　入力１次元ver.

data {
   int<lower=1> N1;
   int<lower=1> N2;
   vector[N1] x1;
   vector[N1] y1;
   vector[N2] x2;
}

transformed data {
   int<lower=1> N = N1 + N2;
   vector[N] x;
   vector[N] Mu;
   real vx;
   real delta = 1e-4;

   for (n in 1:N1) x[n] = x1[n];
   for (n in 1:N2) x[N1 + n] = x2[n];
   for (i in 1:N) Mu[i] = 0;
   vx = variance(x);
}

parameters {
   vector[N2] y2;
   vector<lower=0>[3] theta;
   
}

model {
   matrix[N, N] Cov;
   vector[N] y;
   for (n in 1:N1) y[n] = y1[n];
   for (n in 1:N2) y[N1 + n] = y2[n];

   // RBFカーネル
   for (i in 1:N)
      for (j in 1:N)
         Cov[i,j] = theta[1]*exp(-pow(x[i] - x[j],2)/(theta[2]*vx)) + (i==j ? theta[3] : 0.0);
  
   // Cauchyカーネル     
   //for (i in 1:N)
      //for (j in 1:N)
         //Cov[i,j] = theta[1]*(1/(1 + theta[2]*pow(x[i] - x[j],2)/vx)) + (i==j ? theta[3] : 0.0);
   

   y ~ multi_normal(Mu, Cov);
   theta ~ normal(0,1);
}

