import Foundation
import PDFKit
import UIKit

/// Servicio para generar PDFs con historial de guardias
class PDFExportService {
    
    enum ExportPeriod {
        case month(Date)
        case year(Int)
        case all
        
        var title: String {
            switch self {
            case .month(let date):
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "es_ES")
                formatter.dateFormat = "MMMM yyyy"
                return formatter.string(from: date).capitalized
            case .year(let year):
                return "Año \(year)"
            case .all:
                return "Todo el historial"
            }
        }
    }
    
    /// Genera un PDF con el historial de guardias
    static func generatePDF(
        user: User,
        period: ExportPeriod,
        guardias: [Guardia]
    ) -> Data? {
        let pageWidth: CGFloat = 595.28 // A4
        let pageHeight: CGFloat = 841.89
        let margin: CGFloat = 50
        let contentWidth = pageWidth - (margin * 2)
        
        let pdfMetaData = [
            kCGPDFContextCreator: "MedSalary",
            kCGPDFContextAuthor: user.name,
            kCGPDFContextTitle: "Informe de Guardias - \(period.title)"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight),
            format: format
        )
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = margin
            
            // Title
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let title = "Informe de Guardias"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += 35
            
            // Subtitle with period
            let subtitleFont = UIFont.systemFont(ofSize: 14)
            let subtitle = period.title
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: subtitleFont,
                .foregroundColor: UIColor.gray
            ]
            subtitle.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 30
            
            // User info
            let infoFont = UIFont.systemFont(ofSize: 12)
            let infoAttributes: [NSAttributedString.Key: Any] = [
                .font: infoFont,
                .foregroundColor: UIColor.darkGray
            ]
            
            let userInfo = "Usuario: \(user.name)"
            userInfo.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: infoAttributes)
            yPosition += 20
            
            if let perfil = user.perfil {
                let ccaaInfo = "CCAA: \(perfil.ccaa.displayName) | Categoría: \(perfil.categoria.displayName)"
                ccaaInfo.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: infoAttributes)
                yPosition += 20
            }
            
            let dateInfo = "Generado: \(formatDate(Date()))"
            dateInfo.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: infoAttributes)
            yPosition += 40
            
            // Summary section
            let sectionFont = UIFont.boldSystemFont(ofSize: 16)
            let sectionAttributes: [NSAttributedString.Key: Any] = [
                .font: sectionFont,
                .foregroundColor: UIColor.black
            ]
            
            "Resumen".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25
            
            // Calculate totals
            let totalGuardias = guardias.count
            let totalHoras = guardias.reduce(0) { $0 + $1.horas }
            var totalBruto: Double = 0
            
            if let perfil = user.perfil,
               let config = SalaryEngine.getConfig(ccaa: perfil.ccaa, categoria: perfil.categoria) {
                totalBruto = guardias.reduce(0.0) { total, guardia in
                    total + Double(guardia.horas) * config.precioGuardia.precio(para: guardia.tipo)
                }
            }
            
            let summaryItems = [
                "Total guardias: \(totalGuardias)",
                "Total horas: \(totalHoras)h",
                "Bruto guardias: \(String(format: "%.2f", totalBruto))€"
            ]
            
            for item in summaryItems {
                item.draw(at: CGPoint(x: margin + 20, y: yPosition), withAttributes: infoAttributes)
                yPosition += 18
            }
            yPosition += 20
            
            // Table header
            "Detalle de Guardias".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25
            
            // Table
            let tableHeaderFont = UIFont.boldSystemFont(ofSize: 10)
            let tableCellFont = UIFont.systemFont(ofSize: 10)
            
            let columns: [(String, CGFloat)] = [
                ("Fecha", 100),
                ("Tipo", 80),
                ("Horas", 50),
                ("Hospital", 150),
                ("Importe", 80)
            ]
            
            // Draw header row
            var xPos = margin
            for (header, width) in columns {
                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: tableHeaderFont,
                    .foregroundColor: UIColor.white
                ]
                
                // Header background
                let rect = CGRect(x: xPos, y: yPosition, width: width, height: 20)
                UIColor(red: 0.2, green: 0.6, blue: 0.6, alpha: 1.0).setFill()
                UIBezierPath(rect: rect).fill()
                
                header.draw(at: CGPoint(x: xPos + 5, y: yPosition + 4), withAttributes: headerAttributes)
                xPos += width
            }
            yPosition += 20
            
            // Draw data rows
            let sortedGuardias = guardias.sorted { $0.fecha > $1.fecha }
            
            for (index, guardia) in sortedGuardias.enumerated() {
                // Check if we need a new page
                if yPosition > pageHeight - margin - 30 {
                    context.beginPage()
                    yPosition = margin
                }
                
                var importe: Double = 0
                if let perfil = user.perfil,
                   let config = SalaryEngine.getConfig(ccaa: perfil.ccaa, categoria: perfil.categoria) {
                    importe = Double(guardia.horas) * config.precioGuardia.precio(para: guardia.tipo)
                }
                
                let rowData: [(String, CGFloat)] = [
                    (formatDate(guardia.fecha), 100),
                    (guardia.tipo.displayName, 80),
                    ("\(guardia.horas)h", 50),
                    (guardia.hospital ?? "-", 150),
                    ("\(String(format: "%.2f", importe))€", 80)
                ]
                
                // Alternate row colors
                let backgroundColor = index % 2 == 0 ? UIColor(white: 0.95, alpha: 1) : UIColor.white
                
                xPos = margin
                for (value, width) in rowData {
                    let rect = CGRect(x: xPos, y: yPosition, width: width, height: 18)
                    backgroundColor.setFill()
                    UIBezierPath(rect: rect).fill()
                    
                    let cellAttributes: [NSAttributedString.Key: Any] = [
                        .font: tableCellFont,
                        .foregroundColor: UIColor.black
                    ]
                    
                    // Truncate text if needed
                    let truncated = String(value.prefix(Int(width / 6)))
                    truncated.draw(at: CGPoint(x: xPos + 5, y: yPosition + 3), withAttributes: cellAttributes)
                    xPos += width
                }
                yPosition += 18
            }
            
            // Footer
            yPosition = pageHeight - margin
            let footerText = "MedSalary - Calculadora de salarios para médicos"
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 8),
                .foregroundColor: UIColor.gray
            ]
            footerText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: footerAttributes)
        }
        
        return data
    }
    
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}
