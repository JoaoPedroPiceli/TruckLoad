import std.stdio; 
import std.conv;   

int somar(int a, int b) {
    return a + b;
}

void main() {

    string nome;
    string entrada;

    write("Digite seu nome: ");
    readln(nome); 

    write("Digite sua idade: ");
    readln(entrada); 
    int idade = to!int(entrada); 

    if (idade >= 18) {
        writeln("Você é maior de idade.");
    } else {
        writeln("Você é menor de idade.");
    }

    writeln("\nContando de 1 a 3 com for:");
    for (int i = 1; i <= 3; i++) {
        writeln(i);
    }

    int[] numeros = [10, 20, 30];
    writeln("\nElementos da lista (foreach):");
    foreach (n in numeros) {
        writeln(n);
    }

    int resultado = somar(7, 3);
    writeln("\nResultado da soma: ", resultado);

    // === Escopo com scope(exit) ===
    {
        writeln("\nEntrou em um bloco de escopo.");
        scope(exit) writeln("-> Você saiu do bloco.");
        writeln("Executando algo dentro do bloco...");
    }
}
