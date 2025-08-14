import std.stdio;
import std.conv; // Para converter string → int

// Função que soma dois números inteiros
int somar(int a, int b) {
    return a + b;
}

void main() {
    // Declara variáveis
    string nome;
    string entrada;
    int idade;

    // Lê nome do usuário
    write("Digite seu nome: ");
    readln(nome);

    // Lê idade do usuário como string e converte para int
    write("Digite sua idade: ");
    readln(entrada);
    idade = to!int(entrada);

    // Mostra os dados digitados
    writeln("\nNome: ", nome);
    writeln("Idade: ", idade);

    // Estrutura de decisão
    if (idade >= 18) {
        writeln("Você é maior de idade.");
    } else {
        writeln("Você é menor de idade.");
    }

    // Laço for
    writeln("\nContando até 3:");
    for (int i = 1; i <= 3; i++) {
        writeln(i);
    }

    // Lista e foreach
    int[] numeros = [5, 10, 15];
    writeln("\nElementos da lista:");
    foreach (n in numeros) {
        writeln(n);
    }

    // Usando a função 'somar'
    int resultado = somar(7, 3);
    writeln("\nResultado de 7 + 3: ", resultado);

    // Bloco com scope(exit)
    {
        writeln("\nEntrando no bloco.");
        scope(exit) writeln("Saindo do bloco.");
        writeln("Dentro do bloco.");
    }
}
