import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "list", "card", "location", "temp", "desc", "icon", "feels", "min", "max", "humidity", "pressure", "loader", "cacheBadge"]
    static values = {
        delay: 500,
        minChars: 3
    }

    timeoutId = null
    activeIndex = -1
    abortController = null

    search() {
        const query = this.inputTarget.value.trim()

        if (this.timeoutId) clearTimeout(this.timeoutId)

        if (query.length < this.minCharsValue) {
            this.clearList()
            this.hideList()
            this.resetActive()
            return
        }

        this.timeoutId = setTimeout(() => this.fetchAndRender(query), this.delayValue)
    }

    async fetchAndRender(query) {
        if (this.abortController) this.abortController.abort()
        this.abortController = new AbortController()

        try {
            const response = await fetch(`/api/locations/search?q=${encodeURIComponent(query)}`,
                {headers: {Accept: "application/json"}, signal: this.abortController.signal})

            if (!response.ok) throw new Error(`HTTP ${response.status}`)
            const results = await response.json()
            this.renderList(results)
        } catch (e) {
            if (e.name === "AbortError") return
            this.clearList()
            this.hideList()
            this.resetActive()
        }
    }

    renderList(results) {
        this.clearList()

        if (!Array.isArray(results) || results.length === 0) {
            this.hideList()
            return
        }

        const frag = document.createDocumentFragment()
        results.forEach((result, index) => {
            const li = document.createElement("li")
            li.id = result.zip
            li.textContent = result.formatted_address
            li.className = "combobox-item p-2.5 cursor-pointer rounded-lg hover:bg-slate-100"
            li.dataset.index = String(index)
            li.dataset.zip = result.zip || ""
            li.dataset.countryCode = result.country_code || result.country || ""
            li.setAttribute("role", "option")
            li.addEventListener("mousedown", () => this.select(result))
            frag.appendChild(li)
        })
        this.listTarget.appendChild(frag)

        this.resetActive()
        this.showList()
    }

    select(result) {
        const formatted = result.formatted_address || ''
        const zip = result.zip || ''
        const countryCode = result.country_code || ''
        this.inputTarget.value = formatted
        this.clearList()
        this.hideList()
        this.resetActive()
        if (zip && countryCode) {
            this.fetchWeather(zip, countryCode)
        }
    }

    navigate(event) {
        const items = this.items()
        if (items.length === 0) return

        switch (event.key) {
            case "ArrowDown":
                event.preventDefault()
                this.moveActive(1)
                break
            case "ArrowUp":
                event.preventDefault()
                this.moveActive(-1)
                break
            case "Enter":
                if (this.activeIndex >= 0) {
                    event.preventDefault()
                    const li = items[this.activeIndex]
                    const result = {
                        formatted_address: li.textContent,
                        zip: li.dataset.zip,
                        country_code: li.dataset.countryCode
                    }
                    this.select(result)
                }
                break
            case "Escape":
                this.hideList()
                break
        }
    }

    moveActive(delta) {
        const items = this.items()
        if (items.length === 0) return
        this.activeIndex = (this.activeIndex + delta + items.length) % items.length
        this.updateActive()
    }

    updateActive() {
        const items = this.items()
        items.forEach((item, i) => {
            item.classList.toggle("active", i === this.activeIndex)
            if (i === this.activeIndex) {
                item.setAttribute("aria-selected", "true")
                item.scrollIntoView({block: "nearest"})
            } else {
                item.removeAttribute("aria-selected")
            }
        })
    }

    items() {
        return this.listTarget.querySelectorAll(".combobox-item")
    }

    clearList() {
        this.listTarget.innerHTML = ""
    }

    hideList() {
        this.listTarget.classList.add("hidden")
        this.listTarget.setAttribute("aria-hidden", "true")
    }

    showList() {
        this.listTarget.classList.remove("hidden")
        this.listTarget.removeAttribute("aria-hidden")
    }

    resetActive() {
        this.activeIndex = -1
        this.updateActive()
    }

    async fetchWeather(zip, countryCode) {
        try {
            this.setLoading(true)
            const url = `/api/weather/forecast?zip_code=${encodeURIComponent(zip)}&country_code=${encodeURIComponent(countryCode)}`
            const response = await fetch(url, {headers: {Accept: "application/json"}})
            if (!response.ok) throw new Error(`HTTP ${response.status}`)
            const data = await response.json()
            this.updateWeatherUI(data)
        } catch (e) {
            console.error(e)
            this.resetWeatherUI()
            this.showError("Could not load weather. Please try a US address")
        } finally {
            this.setLoading(false)
        }
    }

    setLoading(isLoading) {
        if (this.hasLoaderTarget) {
            this.loaderTarget.classList.toggle("hidden", !isLoading)
        }
        if (this.hasCardTarget) {
            this.cardTarget.classList.toggle("loading", isLoading)
        }
    }

    updateWeatherUI(data) {
        if (!data) return
        const name = data.name || ""
        const weather = Array.isArray(data.weather) ? data.weather[0] : null
        const main = data.main || {}
        const icon = weather && weather.icon ? `https://openweathermap.org/img/wn/${weather.icon}@2x.png` : undefined
        const desc = weather ? weather.description : ""
        const temp = this.formatTemp(main.temp)
        const feels = this.formatTemp(main.feels_like)
        const min = this.formatTemp(main.temp_min)
        const max = this.formatTemp(main.temp_max)
        const cached = !!data.cached

        if (this.hasLocationTarget) this.locationTarget.textContent = name
        if (this.hasDescTarget) this.descTarget.textContent = this.titleCase(desc)
        if (this.hasTempTarget) this.tempTarget.textContent = temp
        if (this.hasFeelsTarget) this.feelsTarget.textContent = `Feels like ${feels}`
        if (this.hasMinTarget) this.minTarget.textContent = `Low ${min}`
        if (this.hasMaxTarget) this.maxTarget.textContent = `High ${max}`
        if (this.hasHumidityTarget && typeof main.humidity !== 'undefined') this.humidityTarget.textContent = `${main.humidity}% humidity`
        if (this.hasPressureTarget && typeof main.pressure !== 'undefined') this.pressureTarget.textContent = `${main.pressure} hPa`
        if (this.hasIconTarget && icon) {
            this.iconTarget.src = icon
            this.iconTarget.alt = desc
            this.iconTarget.classList.remove("hidden")
        } else {
            this.iconTarget.classList.add("hidden")
        }

        if (this.hasCacheBadgeTarget) {
            this.cacheBadgeTarget.classList.toggle("hidden", !cached)
        }

        if (this.hasCardTarget) {
            this.cardTarget.classList.add("show")
        }
    }

    formatTemp(value) {
        if (typeof value !== 'number') return "--"
        return `${Math.round(value)}°C`
    }

    titleCase(str) {
        return (str || '').replace(/\w\S*/g, (w) => w.charAt(0).toUpperCase() + w.slice(1))
    }

    showError(msg) {
        if (this.hasDescTarget) this.descTarget.textContent = msg
        if (this.hasCardTarget) this.cardTarget.classList.add("show")
    }

    resetWeatherUI() {
        if (this.hasLocationTarget) this.locationTarget.textContent = ""
        if (this.hasIconTarget) this.iconTarget.classList.add("hidden")
        if (this.hasTempTarget) this.tempTarget.textContent = "--"
        if (this.hasFeelsTarget) this.feelsTarget.textContent = ""
        if (this.hasMinTarget) this.minTarget.textContent = ""
        if (this.hasMaxTarget) this.maxTarget.textContent = ""
        if (this.hasHumidityTarget) this.humidityTarget.textContent = ""
        if (this.hasPressureTarget) this.pressureTarget.textContent = ""
        if (this.hasCacheBadgeTarget) this.cacheBadgeTarget.classList.add("hidden")
    }
}