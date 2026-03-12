using ConfidantPostgreSQL.Modules.Product.Repository;
using Microsoft.Extensions.Logging;
using Synget.ERPIntegrator;
using Synget.ERPIntegrator.Models;

namespace ConfidantPostgreSQL.Integrations.Moloni
{
    /// <summary>
    /// Serviço de orquestração para integração de encomendas com Moloni
    /// Implementa os fluxos descritos nos diagramas Mermaid:
    /// - 01: Fluxo completo de encomenda
    /// - 02: Gestão de produtos
    /// - 03: Gestão de clientes
    /// - 04: Sincronização de stock
    /// </summary>
    public sealed class MoloniOrderOrchestrator
    {
        private readonly IMoloniService _moloni;
        private readonly IProductsRepository _productsRepo;
        private readonly ILogger<MoloniOrderOrchestrator> _logger;

        public MoloniOrderOrchestrator(IMoloniService moloni, IProductsRepository productsRepo, ILogger<MoloniOrderOrchestrator> logger)
        {
            _moloni = moloni;
            _productsRepo = productsRepo;
            _logger = logger;
        }

        #region Diagrama 01 - Fluxo Completo de Encomenda

        /// <summary>
        /// PASSO 1: Cliente cria encomenda → Reservar stock no Moloni
        /// Cria uma nota de encomenda no Moloni que reserva o stock
        /// </summary>
        public async Task<OrderReservationResult> ReserveStockForOrderAsync(
            Guid orderId,
            int? userId,
            string customerName,
            string customerVat,
            string customerEmail,
            List<OrderLineDto> lines,
            CancellationToken cancellationToken = default)
        {
            if (!_moloni.IsEnabled)
            {
                _logger.LogWarning("Moloni não está ativo - stock não será reservado para encomenda {OrderId}", orderId);
                return new OrderReservationResult
                {
                    Success = false,
                    Message = "ERP não está configurado",
                    MoloniDocumentId = null
                };
            }

            try
            {
                // Criar cliente no Moloni (se não existir será criado)
                var customer = new ERPCustomer
                {
                    ID = userId?.ToString() ?? string.Empty,
                    Name = customerName,
                    VAT = customerVat
                    // Email não está disponível na API ERPCustomer
                };

                // Criar documento de encomenda
                var document = new ERPDocument
                {
                    ID = orderId.ToString("N"),
                    Type = ERPDocumentType.PurchaseOrder,
                    Date = DateTime.UtcNow,
                    Customer = customer,
                    Lines = lines.Select(l => {
                        // Converter preço COM IVA para preço SEM IVA se necessário
                        // Fórmula: Preço sem IVA = Preço com IVA / (1 + taxa/100)
                        double priceWithoutVat;
                        if (l.IsPriceWithoutVat)
                        {
                            priceWithoutVat = (double)l.UnitPrice;
                        }
                        else
                        {
                            priceWithoutVat = l.TaxRate > 0 
                                ? (double)l.UnitPrice / (1 + l.TaxRate / 100.0) 
                                : (double)l.UnitPrice;
                            priceWithoutVat = Math.Round(priceWithoutVat, 6);
                        }
                        
                        return new ERPDocumentLine
                        {
                            ProductID = l.MoloniProductId ?? string.Empty,
                            Description = l.ProductName ?? string.Empty,
                            Quantity = l.Quantity,
                            Price = priceWithoutVat,
                            TaxID = l.TaxId ?? string.Empty,
                            TaxValue = l.TaxRate
                        };
                    }).ToList()
                };

                var documentId = _moloni.CreatePurchaseOrder(document);

                if (string.IsNullOrEmpty(documentId))
                {
                    _logger.LogError("Falha ao criar encomenda no Moloni: {Message}", _moloni.LastMessage);
                    return new OrderReservationResult
                    {
                        Success = false,
                        Message = _moloni.LastMessage,
                        MoloniDocumentId = null
                    };
                }

                _logger.LogInformation("Stock reservado no Moloni para encomenda {OrderId}, documento: {DocumentId}",
                    orderId, documentId);

                return new OrderReservationResult
                {
                    Success = true,
                    Message = "Stock reservado com sucesso",
                    MoloniDocumentId = documentId
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao reservar stock para encomenda {OrderId}", orderId);
                return new OrderReservationResult
                {
                    Success = false,
                    Message = ex.Message,
                    MoloniDocumentId = null
                };
            }
        }

        /// <summary>
        /// PASSO 2A: Pagamento confirmado → Criar/atualizar cliente e converter encomenda em fatura
        /// Fluxo conforme Diagrama 03 - Gestão de Clientes:
        /// 1. Criar/atualizar cliente no Moloni (só quando pagamento confirmado)
        /// 2. Converter encomenda em fatura-recibo
        /// </summary>
        public async Task<InvoiceResult> CreateInvoiceFromOrderAsync(
            string moloniDocumentId,
            CustomerDto customerData,
            CancellationToken cancellationToken = default)
        {
            if (!_moloni.IsEnabled)
            {
                return new InvoiceResult
                {
                    Success = false,
                    Message = "ERP não está configurado"
                };
            }

            try
            {
                // DIAGRAMA 03: Criar/atualizar cliente no Moloni (só após pagamento confirmado)
                // Converter código ISO do país para ID numérico do Moloni
                var countryId = GetMoloniCountryId(customerData.Country);
                
                var customer = new ERPCustomer
                {
                    Name = customerData.Name,
                    VAT = customerData.Vat,
                    Address = customerData.Address,
                    ZipCode = customerData.ZipCode,
                    City = customerData.City,
                    CountryID = countryId
                };

                // Primeiro guardar/atualizar o cliente no Moloni
                var customerSaved = _moloni.SaveCustomer(customer);
                if (!customerSaved)
                {
                    _logger.LogWarning("Não foi possível criar/atualizar cliente {CustomerName} no Moloni: {Message}. A continuar com fatura...",
                        customerData.Name, _moloni.LastMessage);
                    // Não falhar - continuar com fatura mesmo que cliente não seja guardado
                }
                else
                {
                    _logger.LogInformation("Cliente {CustomerName} (NIF: {VAT}) criado/atualizado no Moloni",
                        customerData.Name, customerData.Vat);
                }

                // Criar fatura-recibo a partir da encomenda
                var invoice = _moloni.InvoicePurchaseOrder(moloniDocumentId, customer);

                if (invoice == null)
                {
                    return new InvoiceResult
                    {
                        Success = false,
                        Message = _moloni.LastMessage
                    };
                }

                _logger.LogInformation("Fatura {InvoiceId} criada no Moloni para documento {DocumentId}",
                    invoice.ID, moloniDocumentId);

                return new InvoiceResult
                {
                    Success = true,
                    Message = "Fatura criada com sucesso",
                    InvoiceId = invoice.ID,
                    InvoicePdf = invoice.PDF
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao criar fatura para documento {DocumentId}", moloniDocumentId);
                return new InvoiceResult
                {
                    Success = false,
                    Message = ex.Message
                };
            }
        }

        /// <summary>
        /// Obtém o link do PDF da fatura para disponibilizar ao cliente
        /// </summary>
        public string? GetInvoicePdfLink(string invoiceId, bool signed = false)
        {
            if (!_moloni.IsEnabled)
            {
                _logger.LogWarning("Moloni não está ativo - não é possível obter PDF");
                return null;
            }

            if (string.IsNullOrWhiteSpace(invoiceId))
            {
                _logger.LogWarning("ID da fatura não especificado para obter PDF");
                return null;
            }

            try
            {
                var pdfUrl = _moloni.GetDocumentPdfLink(invoiceId, signed);
                
                if (!string.IsNullOrWhiteSpace(pdfUrl))
                {
                    _logger.LogInformation("Link do PDF obtido para fatura {InvoiceId}", invoiceId);
                }
                else
                {
                    _logger.LogWarning("Não foi possível obter PDF da fatura {InvoiceId}: {Message}", 
                        invoiceId, _moloni.LastMessage);
                }

                return pdfUrl;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter PDF da fatura {InvoiceId}", invoiceId);
                return null;
            }
        }

        /// <summary>
        /// Cria uma fatura completa para uma ordem que ainda não tem documento Moloni válido.
        /// Este método faz o fluxo completo: criar PurchaseOrder → converter em Invoice → obter PDF URL.
        /// Utilizado para recuperar orders que têm MoloniDocumentId = "pending".
        /// </summary>
        public async Task<CompleteInvoiceResult> CreateCompleteInvoiceAsync(
            Guid orderId,
            int? userId,
            CustomerDto customerData,
            List<OrderLineDto> lines,
            CancellationToken cancellationToken = default)
        {
            if (!_moloni.IsEnabled)
            {
                _logger.LogWarning("Moloni não está ativo - não é possível criar fatura para encomenda {OrderId}", orderId);
                return new CompleteInvoiceResult
                {
                    Success = false,
                    Message = "ERP não está configurado"
                };
            }

            if (lines == null || lines.Count == 0)
            {
                _logger.LogWarning("Encomenda {OrderId} não tem itens para criar fatura", orderId);
                return new CompleteInvoiceResult
                {
                    Success = false,
                    Message = "Encomenda não tem itens"
                };
            }

            try
            {
                _logger.LogInformation("A criar fatura completa para encomenda {OrderId} com {ItemCount} itens", 
                    orderId, lines.Count);

                // PASSO 1: Criar PurchaseOrder no Moloni
                var reservationResult = await ReserveStockForOrderAsync(
                    orderId, userId, customerData.Name, customerData.Vat, customerData.Email, lines, cancellationToken);

                if (!reservationResult.Success || string.IsNullOrWhiteSpace(reservationResult.MoloniDocumentId))
                {
                    _logger.LogError("Falha ao criar PurchaseOrder para encomenda {OrderId}: {Message}", 
                        orderId, reservationResult.Message);
                    return new CompleteInvoiceResult
                    {
                        Success = false,
                        Message = $"Falha ao criar documento de encomenda: {reservationResult.Message}"
                    };
                }

                _logger.LogInformation("PurchaseOrder criada: {DocumentId}", reservationResult.MoloniDocumentId);

                // PASSO 2: Converter PurchaseOrder em Invoice (aqui criamos/atualizamos o cliente com morada)
                var invoiceResult = await CreateInvoiceFromOrderAsync(
                    reservationResult.MoloniDocumentId, customerData, cancellationToken);

                if (!invoiceResult.Success || string.IsNullOrWhiteSpace(invoiceResult.InvoiceId))
                {
                    _logger.LogError("Falha ao converter PurchaseOrder em Invoice para encomenda {OrderId}: {Message}", 
                        orderId, invoiceResult.Message);
                    return new CompleteInvoiceResult
                    {
                        Success = false,
                        Message = $"Falha ao criar fatura: {invoiceResult.Message}",
                        MoloniDocumentId = reservationResult.MoloniDocumentId
                    };
                }

                _logger.LogInformation("Invoice criada: {InvoiceId}", invoiceResult.InvoiceId);

                // PASSO 3: Obter PDF URL
                var pdfUrl = GetInvoicePdfLink(invoiceResult.InvoiceId, signed: false);

                if (string.IsNullOrWhiteSpace(pdfUrl))
                {
                    _logger.LogWarning("Invoice criada mas não foi possível obter PDF URL para encomenda {OrderId}", orderId);
                    // Não falhar - a fatura foi criada, apenas o PDF não foi obtido
                }

                _logger.LogInformation("Fatura completa criada com sucesso para encomenda {OrderId}. Invoice: {InvoiceId}, PDF: {PdfUrl}", 
                    orderId, invoiceResult.InvoiceId, pdfUrl ?? "(não disponível)");

                return new CompleteInvoiceResult
                {
                    Success = true,
                    Message = "Fatura criada com sucesso",
                    MoloniDocumentId = invoiceResult.InvoiceId,
                    MoloniDocumentUrl = pdfUrl
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao criar fatura completa para encomenda {OrderId}", orderId);
                return new CompleteInvoiceResult
                {
                    Success = false,
                    Message = ex.Message
                };
            }
        }

        /// <summary>
        /// PASSO 2B: Encomenda cancelada → Libertar stock reservado
        /// </summary>
        public async Task<bool> CancelOrderReservationAsync(
            string moloniDocumentId,
            CancellationToken cancellationToken = default)
        {
            if (!_moloni.IsEnabled)
            {
                _logger.LogWarning("Moloni não está ativo - reserva não será cancelada");
                return false;
            }

            if (string.IsNullOrWhiteSpace(moloniDocumentId))
            {
                _logger.LogWarning("Documento Moloni não especificado para cancelamento");
                return false;
            }

            try
            {
                var result = _moloni.CancelPurchaseOrder(moloniDocumentId);
                
                if (result)
                {
                    _logger.LogInformation("Reserva cancelada no Moloni: {DocumentId}", moloniDocumentId);
                }
                else
                {
                    _logger.LogWarning("Falha ao cancelar reserva {DocumentId}: {Message}", 
                        moloniDocumentId, _moloni.LastMessage);
                }

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao cancelar reserva {DocumentId}", moloniDocumentId);
                return false;
            }
        }

        #endregion

        #region Diagrama 04 - Sincronização de Stock

        /// <summary>
        /// Sincroniza stock do Moloni para a base de dados local.
        /// Segue o fluxo do diagrama:
        /// 1. Obtém produtos com stock do ERP
        /// 2. Reseta todos os stocks locais a zero
        /// 3. Atualiza os stocks com base na listagem do ERP
        /// </summary>
        public async Task<StockSyncResult> SyncStockAsync(int actorUserId, CancellationToken cancellationToken = default)
        {
            if (!_moloni.IsEnabled)
            {
                return new StockSyncResult
                {
                    Success = false,
                    Message = "ERP não está configurado",
                    ProductsUpdated = 0
                };
            }

            if (actorUserId <= 0)
            {
                return new StockSyncResult
                {
                    Success = false,
                    Message = "Utilizador inválido para sincronização",
                    ProductsUpdated = 0
                };
            }

            try
            {
                // 1. Obter produtos do Moloni
                var products = _moloni.GetProducts(onlyWithStock: false) ?? new List<ERPProduct>();
                _logger.LogInformation("Obtidos {Count} produtos do Moloni para sincronização de stock", products.Count);

                // 2. Resetar todos os stocks locais a zero (conforme diagrama)
                var resetCount = await _productsRepo.ResetAllInventoryToZeroAsync(actorUserId);
                _logger.LogInformation("Resetados {Count} stocks de inventário a zero", resetCount);

                // 3. Atualizar stocks com base na listagem do ERP
                var updated = 0;
                var skipped = 0;

                foreach (var product in products)
                {
                    if (cancellationToken.IsCancellationRequested)
                        break;

                    if (string.IsNullOrWhiteSpace(product.ID))
                    {
                        skipped++;
                        continue;
                    }

                    var instanceId = await _productsRepo.GetInstanceIdByMoloniProductIdAsync(product.ID);
                    if (!instanceId.HasValue)
                    {
                        skipped++;
                        continue;
                    }

                    var qty = (int)Math.Round(product.StockTotal);
                    if (qty < 0) qty = 0;

                    // Só atualiza se o stock for > 0 (os outros já estão a zero do reset)
                    if (qty > 0)
                    {
                        var ok = await _productsRepo.UpsertInventoryQuantityAsync(instanceId.Value, qty, actorUserId);
                        if (ok)
                            updated++;
                        else
                            skipped++;
                    }
                    else
                    {
                        // Stock é zero, já foi resetado, conta como atualizado
                        updated++;
                    }
                }

                return new StockSyncResult
                {
                    Success = true,
                    Message = $"Sincronizados {updated} produtos, resetados {resetCount} registos (ignorados {skipped})",
                    ProductsUpdated = updated,
                    ProductsSkipped = skipped,
                    ProductsReset = resetCount
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao sincronizar stock");
                return new StockSyncResult
                {
                    Success = false,
                    Message = ex.Message,
                    ProductsUpdated = 0,
                    ProductsSkipped = 0
                };
            }
        }

        #endregion

        #region Helpers

        /// <summary>
        /// Converte código ISO 3166-1 alpha-2 do país para ID numérico do Moloni.
        /// Por padrão usa variável de ambiente MOLONI_DEFAULT_COUNTRY_ID ou "1" (Portugal).
        /// </summary>
        private static string GetMoloniCountryId(string? isoCode)
        {
            // Mapeamento de códigos ISO para IDs do Moloni
            // Estes são os IDs usados pela API do Moloni
            var countryMapping = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                { "PT", "1" },   // Portugal
                { "ES", "2" },   // Espanha
                { "FR", "3" },   // França
                { "DE", "4" },   // Alemanha
                { "IT", "5" },   // Itália
                { "GB", "6" },   // Reino Unido
                { "UK", "6" },   // Reino Unido (alternativo)
                { "BR", "32" },  // Brasil
                { "US", "233" }, // Estados Unidos
                { "NL", "156" }, // Países Baixos
                { "BE", "21" },  // Bélgica
                { "CH", "42" },  // Suíça
                { "AT", "14" },  // Áustria
                { "IE", "106" }, // Irlanda
                { "LU", "127" }, // Luxemburgo
            };

            // Se o código ISO está mapeado, usar o ID correspondente
            if (!string.IsNullOrWhiteSpace(isoCode) && countryMapping.TryGetValue(isoCode.Trim(), out var moloniId))
            {
                return moloniId;
            }

            // Se o código já parece ser um ID numérico, usar diretamente
            if (!string.IsNullOrWhiteSpace(isoCode) && int.TryParse(isoCode.Trim(), out _))
            {
                return isoCode.Trim();
            }

            // Usar ID padrão da variável de ambiente ou Portugal (1)
            return Environment.GetEnvironmentVariable("MOLONI_DEFAULT_COUNTRY_ID") ?? "1";
        }

        #endregion
    }

    #region DTOs e Resultados

    public class CustomerDto
    {
        public string Name { get; set; } = string.Empty;
        public string Vat { get; set; } = "999999990";
        public string Email { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string ZipCode { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string Country { get; set; } = "PT";
    }

    public class OrderLineDto
    {
        public string? MoloniProductId { get; set; }
        public string? ProductName { get; set; }
        public int Quantity { get; set; }
        /// <summary>
        /// Preço unitário. Por defeito assume-se que é o PVP (com IVA).
        /// O Moloni espera preço sem IVA, por isso fazemos a conversão automática.
        /// </summary>
        public decimal UnitPrice { get; set; }
        public string? TaxId { get; set; }
        public double TaxRate { get; set; } = 23.0;
        /// <summary>
        /// Se true, o UnitPrice já está sem IVA (não precisa conversão).
        /// Se false (default), o UnitPrice é o PVP com IVA e será convertido.
        /// </summary>
        public bool IsPriceWithoutVat { get; set; } = false;
        /// <summary>
        /// Se true, é um serviço (ex: portes de envio) em vez de produto.
        /// </summary>
        public bool IsService { get; set; } = false;
    }

    public class OrderReservationResult
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public string? MoloniDocumentId { get; set; }
    }

    public class InvoiceResult
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public string? InvoiceId { get; set; }
        public string? InvoicePdf { get; set; }
    }

    public class StockSyncResult
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public int ProductsUpdated { get; set; }
        public int ProductsSkipped { get; set; }
        /// <summary>
        /// Número de registos de inventário que foram resetados a zero
        /// </summary>
        public int ProductsReset { get; set; }
    }

    public class CompleteInvoiceResult
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public string? MoloniDocumentId { get; set; }
        public string? MoloniDocumentUrl { get; set; }
    }

    #endregion
}
