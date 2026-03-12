using Synget.ERPIntegrator.Models;

namespace ConfidantPostgreSQL.Integrations.Moloni
{
    /// <summary>
    /// Interface para integração com Moloni ERP
    /// </summary>
    public interface IMoloniService
    {
        /// <summary>
        /// Indica se o serviço está configurado e ativo
        /// </summary>
        bool IsEnabled { get; }

        /// <summary>
        /// Mensagem de erro/status do último operação
        /// </summary>
        string LastMessage { get; }

        #region Produtos

        /// <summary>
        /// Obtém um produto do Moloni pelo ID
        /// </summary>
        ERPProduct? GetProduct(string productId);

        /// <summary>
        /// Obtém lista de produtos do Moloni
        /// </summary>
        List<ERPProduct> GetProducts(bool onlyWithStock = true);

        /// <summary>
        /// Cria ou atualiza um produto no Moloni
        /// </summary>
        bool SaveProduct(ERPProduct product);

        #endregion

        #region Clientes

        /// <summary>
        /// Cria ou atualiza um cliente no Moloni
        /// </summary>
        bool SaveCustomer(ERPCustomer customer);

        #endregion

        #region Documentos / Encomendas

        /// <summary>
        /// Cria uma encomenda (Purchase Order) no Moloni
        /// Reserva stock automaticamente
        /// </summary>
        /// <param name="document">Documento com linhas de produtos</param>
        /// <returns>ID do documento criado ou null se falhou</returns>
        string? CreatePurchaseOrder(ERPDocument document);

        /// <summary>
        /// Cancela uma encomenda no Moloni
        /// Liberta o stock reservado
        /// </summary>
        bool CancelPurchaseOrder(string documentId);

        /// <summary>
        /// Converte uma encomenda em fatura
        /// Após pagamento confirmado
        /// </summary>
        /// <param name="documentId">ID da encomenda</param>
        /// <param name="customer">Cliente para faturação</param>
        /// <returns>Documento de fatura ou null se falhou</returns>
        ERPDocument? InvoicePurchaseOrder(string documentId, ERPCustomer customer);

        /// <summary>
        /// Obtém um link para o PDF de um documento no Moloni.
        /// Nota: o Moloni devolve um URL (não bytes do PDF).
        /// </summary>
        /// <param name="documentId">ID do documento (invoice, purchase order, etc.)</param>
        /// <param name="signed">Se true tenta obter link assinado quando suportado</param>
        /// <returns>URL do PDF ou null em caso de erro</returns>
        string? GetDocumentPdfLink(string documentId, bool signed = false);

        #endregion

        #region Stock

        /// <summary>
        /// Obtém o stock atual de um produto
        /// </summary>
        int GetProductStock(string productId);

        /// <summary>
        /// Adiciona um movimento de stock no armazém principal
        /// </summary>
        /// <param name="productId">ID do produto no Moloni</param>
        /// <param name="quantity">Quantidade a adicionar (pode ser negativa para remover)</param>
        /// <param name="notes">Notas opcionais para o movimento</param>
        /// <returns>true se sucesso</returns>
        bool AddStockMovement(string productId, int quantity, string? notes = null);

        /// <summary>
        /// Sincroniza stock do Moloni para a base de dados local
        /// </summary>
        Task<int> SyncStockToLocalAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// Obtém o ID do armazém principal configurado
        /// </summary>
        int MainWarehouseId { get; }

        /// <summary>
        /// Obtém o ID do armazém de reserva configurado
        /// </summary>
        int ReserveWarehouseId { get; }

        #endregion
    }
}
