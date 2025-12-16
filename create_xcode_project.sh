#!/bin/bash
# Script para crear proyecto Xcode para MedSalary

PROJECT_DIR="$HOME/Desktop/MedSalaryXcode"

# Crear directorio
mkdir -p "$PROJECT_DIR"

# Copiar archivos Swift
cp -R /Users/vicente.tancoedu.uah.es/med_salary-1/MedSalary/* "$PROJECT_DIR/"

echo "✅ Archivos copiados a: $PROJECT_DIR"
echo ""
echo "Ahora abre Xcode y:"
echo "1. File → New → Project → iOS → App"
echo "2. Product Name: MedSalary"
echo "3. Interface: SwiftUI, Storage: SwiftData"
echo "4. Guárdalo en Desktop"
echo "5. Elimina Item.swift y ContentView.swift generados"
echo "6. Arrastra los archivos de $PROJECT_DIR al proyecto"
echo "7. Cmd+R para ejecutar"
