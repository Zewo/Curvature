// Message.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

extension Message {
    public var buffer: Data {
        mutating get {
            if let drain = body as? Drain {
                return drain.data
            }
            let drain = Drain(body)
            body = drain
            return drain.data
        }

        set(buffer) {
            body = Drain(buffer)
        }
    }
}

extension Message {
    public var contentType: MediaType? {
        get {
            return headers["Content-Type"].first.flatMap({try? MediaType(string: $0)})
        }

        set(contentType) {
            headers["Content-Type"] = contentType.map({[$0.description]}) ?? nil
        }
    }

    public var contentLength: Int? {
        get {
            return headers["Content-Length"].first.flatMap({Int($0)})
        }

        set(contentLength) {
            headers["Content-Length"] = contentLength.map({[$0.description]}) ?? nil
        }
    }

    public var transferEncoding: HeaderValues {
        get {
            return headers["Transfer-Encoding"] ?? []
        }

        set(transferEncoding) {
            headers["Transfer-Encoding"] = transferEncoding
        }
    }

    public var isChunkEncoded: Bool {
        return transferEncoding.contains({$0.lowercased().contains("chunked")})
    }

    public var connection: HeaderValues {
        get {
            return headers["Connection"] ?? []
        }

        set(connection) {
            headers["Connection"] = connection
        }
    }

    public var isKeepAlive: Bool {
        if version.minor == 0 {
            return connection.contains({$0.lowercased().contains("keep-alive")})
        }

        return connection.contains({!$0.lowercased().contains("close")})
    }

    public var isUpgrade: Bool {
        return connection.contains({!$0.lowercased().contains("upgrade")})
    }

    public var upgrade: HeaderValues {
        get {
            return headers["Upgrade"] ?? []
        }

        set(upgrade) {
            headers["Upgrade"] = upgrade
        }
    }
}

extension Message {
    public var storageDescription: String {
        var string = "Storage:\n"

        if storage.count == 0 {
            string += "-"
        }

        for (offset: index, element: (key: key, value: value)) in storage.enumerated() {
            string += "\(key): \(value)"

            if index < storage.count - 1 {
                string += "\n"
            }
        }

        return string
    }
}