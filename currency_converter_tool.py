"""
id: currency_converter
name: Currency Converter
description: Convert currencies using real-time exchange rates
requirements: requests, pydantic
"""

import requests
from pydantic import BaseModel, Field


class Valves(BaseModel):
    """Configuración global de la herramienta"""

    api_key: str = Field(
        "",
        description="API Key de ExchangeRate-API (opcional, usa tier gratuito si está vacío)",
    )
    base_currency: str = Field(
        "USD", description="Moneda base por defecto (ISO 4217, ej: USD, EUR, MXN)"
    )


class Tools:
    def __init__(self):
        self.valves = None

    def convert_currency(
        self,
        amount: float = Field(..., description="Cantidad a convertir"),
        from_currency: str = Field(
            ..., description="Moneda origen (ISO 4217, ej: USD, EUR, MXN)"
        ),
        to_currency: str = Field(
            ..., description="Moneda destino (ISO 4217, ej: USD, EUR, MXN)"
        ),
    ) -> str:
        """
        Convierte una cantidad de una moneda a otra usando tasas de cambio en tiempo real.

        Ejemplos de monedas: USD (Dólar), EUR (Euro), MXN (Peso mexicano),
        GBP (Libra esterlina), JPY (Yen japonés), ARS (Peso argentino), etc.
        """
        try:
            # Usar API gratuita de exchangerate-api.com
            if self.valves and self.valves.api_key:
                url = f"https://v6.exchangerate-api.com/v6/{self.valves.api_key}/latest/{from_currency.upper()}"
            else:
                # Fallback a API pública gratuita (limitada)
                url = f"https://api.exchangerate-api.com/v4/latest/{from_currency.upper()}"

            response = requests.get(url, timeout=10)
            data = response.json()

            if response.status_code != 200:
                return f"Error al obtener tasas de cambio: {data.get('error-type', 'Error desconocido')}"

            rates = data.get("rates", {})
            to_code = to_currency.upper()

            if to_code not in rates:
                available = ", ".join(list(rates.keys())[:10]) + "..."
                return f"Moneda '{to_currency}' no encontrada. Monedas disponibles: {available}"

            rate = rates[to_code]
            result = amount * rate

            base = self.valves.base_currency if self.valves else "USD"

            return (
                f"💱 **Conversión de Divisas**\n\n"
                f"• **{amount:,.2f} {from_currency.upper()}** = **{result:,.2f} {to_currency.upper()}**\n"
                f"• Tasa: 1 {from_currency.upper()} = {rate:,.4f} {to_currency.upper()}\n"
                f"• Fecha: {data.get('date', 'N/A')}\n"
                f"• Fuente: ExchangeRate-API"
            )

        except requests.exceptions.RequestException as e:
            return f"Error de conexión: {str(e)}"
        except Exception as e:
            return f"Error inesperado: {str(e)}"

    def get_exchange_rates(
        self,
        base_currency: str = Field("USD", description="Moneda base (ISO 4217)"),
        target_currencies: str = Field(
            "EUR,GBP,JPY,MXN", description="Monedas destino separadas por coma"
        ),
    ) -> str:
        """
        Obtiene las tasas de cambio actuales para una moneda base contra varias monedas destino.
        """
        try:
            if self.valves and self.valves.api_key:
                url = f"https://v6.exchangerate-api.com/v6/{self.valves.api_key}/latest/{base_currency.upper()}"
            else:
                url = f"https://api.exchangerate-api.com/v4/latest/{base_currency.upper()}"

            response = requests.get(url, timeout=10)
            data = response.json()

            if response.status_code != 200:
                return f"Error: {data.get('error-type', 'Error desconocido')}"

            rates = data.get("rates", {})
            targets = [c.strip().upper() for c in target_currencies.split(",")]

            result_lines = [f"📊 **Tasas de Cambio - {base_currency.upper()}**\n"]
            result_lines.append(f"Fecha: {data.get('date', 'N/A')}\n")
            result_lines.append("```")

            for currency in targets:
                if currency in rates:
                    result_lines.append(
                        f"1 {base_currency.upper()} = {rates[currency]:,.4f} {currency}"
                    )

            result_lines.append("```")
            return "\n".join(result_lines)

        except Exception as e:
            return f"Error: {str(e)}"
